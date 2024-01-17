locals {
  repo_name          = var.repo_name == null ? var.ecr_config.repo_name : var.repo_name
  replication_config = var.replication_config == null ? var.ecr_config.replication_config : var.replication_config
  replication_policy = var.replication_config == null ? var.ecr_config.replication_policy : var.replication_policy
  principal          = var.principal == null ? var.ecr_config.principal : var.principal
}

resource "aws_ecr_repository" "main" {
  name = local.repo_name
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Expire untagged images older than 1 days",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 1
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "adds full ecr access to the ${local.repo_name} repository",
          "Effect": "Allow",
          "Principal": ${local.principal},
          "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:BatchGetImage",
              "ecr:CompleteLayerUpload",
              "ecr:GetDownloadUrlForLayer",
              "ecr:GetLifecyclePolicy",
              "ecr:InitiateLayerUpload",
              "ecr:PutImage",
              "ecr:UploadLayerPart",
              "ecr:ReplicateImage",
              "ecr:CreateRepository",
              "ecr:DescribeImages",
              "ecr:DescribeRepositories",
              "ecr:GetRepositoryPolicy",
              "ecr:ListImages"
          ]
        }
      ]
    }
    EOF
}

resource "aws_ecr_replication_configuration" "main" {
  count = local.replication_config.enabled ? 1 : 0
  replication_configuration {
    rule {
      destination {
        region      = local.replication_config.region
        registry_id = local.replication_config.registry_id
      }
    }
  }
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "replication" {
  count = local.replication_policy.account_id != "" ? 1 : 0
  statement {
    sid    = "${var.repo_name}-replication-access"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${local.replication_policy.account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage"
    ]
    resources = ["arn:aws:ecr:${local.replication_policy.region}:${data.aws_caller_identity.this.id}:repository/${local.repo_name}"]
  }
}

resource "aws_ecr_registry_policy" "this" {
  count  = local.replication_policy.account_id != "" ? 1 : 0
  policy = data.aws_iam_policy_document.replication[0].json
}

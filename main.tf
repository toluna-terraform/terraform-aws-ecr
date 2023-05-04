resource "aws_ecr_repository" "main" {
  name = var.repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
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
          "Sid": "adds full ecr access to the ${var.repo_name} repository",
          "Effect": "Allow",
          "Principal": ${var.principal},
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
  count = var.replication_config.enabled ? 1 : 0
  replication_configuration {
    rule {
      destination {
        region      = var.replication_config.region
        registry_id = var.replication_config.registry_id
      }
    }
  }
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "replication" {
  count = var.replication_policy.account_id != "" ? 1 : 0
  statement {
    sid    = "${var.repo_name}-replication-access"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${var.replication_policy.account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage"
    ]
    resources = ["arn:aws:ecr:${var.replication_policy.region}:${data.aws_caller_identity.this.id}:repository/${var.repo_name}"]
  }
}

resource "aws_ecr_registry_policy" "this" {
  count  = var.replication_policy.account_id != "" ? 1 : 0
  policy = data.aws_iam_policy_document.replication[0].json
}
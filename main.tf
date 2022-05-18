resource "aws_ecr_repository" "main" {
  name = var.repo_name
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
            "Principal": "*",
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
                "ecr:CreateRepository"
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

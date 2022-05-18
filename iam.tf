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
provider "aws" {}


module "ecr" {
  source = "../"

  repo_name = var.ecr_repo_name
}

output "ecr_repo_name" {
  value = module.ecr.repository_name
}

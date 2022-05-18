# terraform-aws-ecs
Toluna terraform module for AWS ECR

## Description
This module creates ECR repository, IAM role and replication configuration (optionally).

## Usage
```hcl
module "ecr" {
  source              = "toluna-terraform/terraform-aws-ecr"
  version             = "~>0.0.1" // Change to the required version.
  repo_name           = "example"
  replication_config  = {
    enabled           = true # false by default
    registry_id       = "243282684219"
    region            = "us-east-1"   
  }
}
```
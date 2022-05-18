variable "repo_name" {
  type = string
}

variable "replication_config" {
  type = object({
    enabled     = bool
    region      = string
    registry_id = string
  })
  default = {
    enabled     = false
    region      = "us-east-1"
    registry_id = ""
  }
}

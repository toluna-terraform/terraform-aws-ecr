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

variable "replication_policy" {
  type = object({
    account_id = string
    region     = string
  })
  default = {
    account_id = ""
    region     = "us-east-1"
  }
}

variable "principal" {
  default = "\"*\""
}
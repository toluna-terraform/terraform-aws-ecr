variable "ecr_config" {
}

variable "repo_name" {
  type     = string
  default  = null
}

variable "replication_config" {
  type = object({
    enabled     = bool
    region      = string
    registry_id = string
  })
  default  = null
}

variable "replication_policy" {
  type = object({
    account_id = string
    region     = string
  })
  default  = null
}

variable "principal" {
  type     = string
  default  = null
}

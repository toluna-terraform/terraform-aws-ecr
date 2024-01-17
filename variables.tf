variable "ecr_config" {
  #type = map(string)
}

variable "repo_name" {
  type     = string
  default  = null
  nullable = true
}

variable "replication_config" {
  type = object({
    enabled     = bool
    region      = string
    registry_id = string
  })
  default  = null
  nullable = true
}

variable "replication_policy" {
  type = object({
    account_id = string
    region     = string
  })
  default  = null
  nullable = true
}

variable "principal" {
  type     = string
  default  = null
  nullable = true
}

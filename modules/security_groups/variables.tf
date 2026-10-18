variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Environment name ( e.g. dev, prod )"
  type        = string
}
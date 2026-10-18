variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}
variable "enable_nat_gateway"{
  description = "enable nat gateway for private subnets"
  type        = bool
  default     = true
}
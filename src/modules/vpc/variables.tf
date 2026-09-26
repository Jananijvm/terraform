variable "environment" {}
variable "purpose" {}

variable "vpc_name" {}
variable "vpc_cidr" {}

variable "enable_dns_support" { type = bool }
variable "enable_dns_hostnames" { type = bool }

variable "rds_port" { type = number }
variable "ssh_port" { type = number }
variable "aurora_port" { type = number }
variable "az_count" {
  description = "How many AZs to use"
  type        = number
}

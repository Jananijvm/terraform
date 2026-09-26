variable "environment" {}
variable "purpose" {}

variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {}

variable "db_identifier" {}
variable "db_name" {}
variable "engine_version" {}
variable "instance_class" {}
variable "storage_gb" { type = number }
variable "max_storage_gb" { type = number }

variable "multi_az" { type = bool }
variable "publicly_accessible" { type = bool }

variable "master_username" {}

variable "backup_retention_days" { type = number }
variable "copy_tags_to_snapshot" {
  type    = bool
  default = false
}

variable "secret_rotation_schedule" {
  type        = string
  description = "Schedule expression for RDS master password rotation"
  default     = "cron(0 0 ? * SUN *)"
}
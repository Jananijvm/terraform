variable "environment" {
  type = string
}

variable "purpose" {
  type = string
}

variable "audit_table_name" {
  description = "DynamoDB table name for audit logs"
  type        = string
  default     = "arocord-hims-audit-logs"
}
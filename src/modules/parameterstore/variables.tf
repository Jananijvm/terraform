variable "db_secret_name" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "db_host" {
  description = "Database endpoint"
  type        = string
}


variable "document_bucket" {
  description = "Insights S3 bucket"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}

variable "arocordins_db_name"{
    type = string
}

variable "zoho_notifier"{
  description = "Zoho notifier secret name"
  type        = string
}
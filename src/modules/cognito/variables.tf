variable "environment" {}
variable "purpose" {}

variable "user_pool_name" {}
variable "app_client_name" {}

variable "refresh_token_days" { type = number }
variable "access_token_days"  { type = number }
variable "id_token_days"      { type = number }

variable "session_minutes" { type = number }

variable "user_groups" {
  type = list(string)
}

variable "callback_urls" {
  type = list(string)
}

variable "logout_urls" {
  type = list(string)
}

variable "domain_prefix" {}

variable "email_subject" {}
variable "email_html" {}
variable "document_bucket_name" {
  description = "Document S3 bucket name"
  type        = string
}

variable "audio_bucket_name" {
  description = "Audio S3 bucket name"
  type        = string
}
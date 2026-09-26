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
variable "secret_rotation_schedule" {
  type        = string
  description = "Schedule expression for RDS master password rotation"
  default     = "cron(0 0 ? * SUN *)"
}




# S3
variable "document_bucket" {}
variable "s3_versioned" {
  type = bool
}
variable "s3_removal_policy" {}
variable "s3_cors_rules" {
  type = any
}


# Cognito
variable "cognito_user_pool_name" {}
variable "cognito_app_client_name" {}

variable "cognito_refresh_token_days" { type = number }
variable "cognito_access_token_days"  { type = number }
variable "cognito_id_token_days"      { type = number }
variable "cognito_session_minutes"    { type = number }

variable "cognito_user_groups" { type = list(string) }

variable "cognito_callback_urls" { type = list(string) }
variable "cognito_logout_urls"   { type = list(string) }

variable "cognito_domain_prefix" {}

variable "cognito_email_subject" {}
variable "cognito_email_html" {}


# AI SUMMARISER PURPOSE


# variable "AURORA_DB_IDENTIFIER" {}
# variable "AURORA_WRITER_IDENTIFIER" {}
# variable "AURORA_ENGINE_VERSION" {}
# variable "AURORA_PORT" {}

# variable "AURORA_DB_USERNAME" {}

# variable "AURORA_BACKUP_RETENTION_DAYS" {}

# variable "AURORA_MIN_ACU" {}
# variable "AURORA_MAX_ACU" {}

# variable "AURORA_REMOVAL_POLICY" {}

variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
}

variable "rds_db_name" {
  type = string
}

variable "arocordins_db_name"{
    type = string
}

# Artifact bucket
variable "artifact_bucket" {
  type = string
}

variable "artifact_base_path" {
  type = string
}

# Layer relative keys
variable "layer_core_key"     { type = string }
variable "layer_pdf_key"      { type = string }
variable "layer_numpy_key"    { type = string }
variable "layer_openai_key"   { type = string }
variable "layer_pymysql_key"  { type = string }
variable "layer_requests_key" { type = string }
variable "layer_jose_key"     { type = string }

variable "app_client_id_arocord_app" {
  type = string
}

variable "user_pool_id_arocord_app" {
  type = string
}

variable "from_email" {
  type = string
}

variable "aggregated_cache_table" {
  type = string
}



variable "bulletin_dynamodb_enabled" {
  type = string
}

variable "clinic_id" {
  type = string
}

variable "comprehend_region" {
  type = string
}

variable "interval_limit" {
  type = string
}

variable "monthly_limit" {
  type = string
}

variable "openai_api_key_1" {
  type = string
}

variable "openai_api_key_2" {
  type = string
}

variable "openai_api_key_3" {
  type = string
}

variable "openai_api_key_4" {
  type = string
}


variable "summary_status_table" {
  type = string
}

variable "usage_records_table" {
  type = string
}

variable "warning_events_table" {
  type = string
}

variable "audio_bucket" {
  type = string
}

variable "deepgram_api_key" {
  type = string
}

variable "s3_deploy_bucket" {
  type = string
}


variable "region" {}
variable "image_tag" {}

variable "patient_api_base"{}

variable "api_keys" {
  type = map(string)
    sensitive = true
}

variable "zoho_notifier" {
  type = map(string)
    sensitive = true
}

variable "arocord_app_region"{}
variable "artifact_region" {}

variable "audit_table_name" {
  type    = string
  default = "arocord-hims-audit-logs"
}

variable "account_id" {}

variable "bus_name" {
  type = string
}

variable "rule_name" {
  type = string
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = false
}

variable "zoho_accounts_url" {
  type = string
}

variable "zoho_api_url" {
  type = string
}

variable "sns_topic_name" {
  type = string
}
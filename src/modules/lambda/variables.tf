variable "environment" {}
variable "purpose" {}

variable "artifact_bucket" {}
variable "artifact_base_path" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "lambda_sg_id" {}

variable "rds_sg_id" {}

variable "document_bucket" {}

variable "db_secret_arn" {}

# AI SUMMARISER PURPOSE
# variable "db_cluster_arn" {}

variable "layer_arns" {
  type = map(string)
}


variable "from_email" {
  type = string
}

variable "aggregated_cache_table" {
  type = string
}

variable "appsync_api_url" {
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

variable "openai_api_key" {
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

# AI SUMMARISER PURPOSE
/*
variable "summarizer_queue_url" {
  type = string
}*/

variable "email_queue_url" {
  type = string
}

variable "refine_queue_url" {
  type = string
}

variable "soap_queue_url" {
  type = string
}

variable "transcribe_queue_url" {
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

variable "app_client_id_arocord_app" {
  type = string
}

variable "user_pool_id_arocord_app" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_app_client_id" {
  type = string
}

variable "policy_arns" {
  type = map(string)
  description = "Map of policy names to their ARNs"
}



variable "transcript_appsync_api_url" {
  type = string
  description = "Transcript AppSync API URL"
}

variable "transcript_jobs_table_name" {
  type = string
  description = "DynamoDB table name for transcript jobs"
}
variable "account_id" {}
variable "region" {}
variable "image_tag" {}

variable "api_secret_keys"{}

variable "patient_api_base"{}

variable "arocord_app_region"{}

variable "zoho_notifier_parameter_name" {
    type = string
}

variable "zoho_accounts_url" {
  type = string
}

variable "zoho_api_url" {
  type = string
}

variable "zoho_notifier_sns_topic_arn" {
  type = string
}
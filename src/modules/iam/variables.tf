variable "document_bucket_name" {
  description = "Document S3 bucket name"
  type        = string
}

variable "audio_bucket_name" {
  description = "Audio S3 bucket name"
  type        = string
}

variable "cognito_user_pool_arns" {
  description = "List of Cognito User Pool ARNs"
  type        = list(string)
}

variable "sqs_queue_name" {
  description = "SQS queue name"
  type        = string
}

variable "appsync_api_id" {
  description = "AppSync API ID"
  type        = string
}

variable "api_secret_name" {
  description = "Secrets Manager secret name for API keys"
  type        = string
}

variable "transcript_appsync_api_id" {
  description = "Transcript AppSync API ID"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "transcription_lambda_arn" {
  description = "ARN of the transcription Lambda function"
  type        = string
}

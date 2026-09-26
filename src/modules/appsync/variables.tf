variable "user_pool_id" {
  type = string
}

variable "transcription_lambda_arn" {
  type = string
}

variable "transcription_lambda_role" {
  type = string
}

variable "appsync_lambda_invoke_policy_arn" {
  type = string
}

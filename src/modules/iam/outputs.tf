output "rds_connectivity_policy_arn" {
  value = aws_iam_policy.rds_connectivity.arn
}

output "ssm_secrets_and_eventbridge_audit_policy_arn" {
  value = aws_iam_policy.ssm_secrets_and_eventbridge_audit.arn
}

output "ec2_network_interface_policy_arn" {
  value = aws_iam_policy.ec2_network_interface.arn
}

output "s3_artifacts_access_policy_arn" {
  value = aws_iam_policy.s3_artifacts_access.arn
}

output "rds_data_api_policy_arn" {
  value = aws_iam_policy.rds_data_api.arn
}

output "ses_email_access_policy_arn" {
  value = aws_iam_policy.ses_email_access.arn
}

output "sqs_send_policy_arn" {
  value = aws_iam_policy.sqs_send.arn
}

output "aisummarizer_manager_policy_arn" {
  value = aws_iam_policy.aisummarizer_manager.arn
}

output "zoho_secret_access_policy_arn" {
  value = aws_iam_policy.zoho_secret_access.arn
}

output "lambda_logging_policy_arn" {
  value = aws_iam_policy.lambda_logging.arn
}

output "lambda_appsync_refinenotes_policy_arn" {
  value = aws_iam_policy.lambda_appsync_refinenotes.arn
}
 
output "lambda_appsync_soapnotes_policy_arn" {
  value = aws_iam_policy.lambda_appsync_soapnotes.arn
}

output "lambda_appsync_email_template_arn"{
value =aws_iam_policy.lambda_appsync_email_template.arn
}

output "lambda_appsync_transcript_arn"{
  value=aws_iam_policy.lambda_appsync_transcription.arn
}
output "lambda_role_policy_arn" {
  value = aws_iam_policy.lambda_role.arn
}

output "arocord_insights_api_keys_policy_arn" {
  value = aws_iam_policy.arocord_insights_api_keys.arn
}

output "worker_lambda_policy_arn" {
  value = aws_iam_policy.worker_lambda.arn
}

output "arocord_insights_cognito_policy_arn" {
  value = aws_iam_policy.arocord_insights_cognito.arn
}

output "appsync_lambda_invoke_policy_arn" {
  value = aws_iam_policy.appsync_lambda_invoke.arn
}

output "dynamodb_audit_policy_arn" {
  value = aws_iam_policy.dynamodb_audit.arn
}

output "zoho_notifier_policy_arn" {
  value = aws_iam_policy.zoho_notifier_policy.arn
}
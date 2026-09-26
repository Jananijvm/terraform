output "parameter_names" {
  value = [
    aws_ssm_parameter.db_secret_name.name,
    aws_ssm_parameter.db_host.name,
    aws_ssm_parameter.arocordins_db_name.name,
    aws_ssm_parameter.s3_bucket.name
  ]
}


output "zoho_notifier_parameter_name" {
  value = aws_ssm_parameter.zoho_notifier_param.name
}
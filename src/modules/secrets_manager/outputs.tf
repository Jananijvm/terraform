output "secret_name" {
  value = aws_secretsmanager_secret.api_keys.name
}

output "zoho_notifier_secret_name" {
  value = aws_secretsmanager_secret.zoho_notifier.name
}
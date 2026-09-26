resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "api_keys" {
  name = "arocordInsightsApiKeys-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "api_keys_value" {
  secret_id     = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode(var.api_keys)

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

resource "aws_secretsmanager_secret" "zoho_notifier" {
  name = "arocord-zoho-sprints-credentials-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "zoho_notifier_value" {
  secret_id     = aws_secretsmanager_secret.zoho_notifier.id
  secret_string = jsonencode(var.zoho_notifier)

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
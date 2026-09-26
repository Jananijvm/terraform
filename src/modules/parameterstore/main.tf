resource "aws_ssm_parameter" "db_secret_name" {
  name  = "DB_AROCORDINS_SECRETNAME"
  type  = "String"
  value = var.db_secret_name
}

resource "aws_ssm_parameter" "db_host" {
  name  = "DB_HOST_AROCORDINS"
  type  = "String"
  value = var.db_host
}

resource "aws_ssm_parameter" "arocordins_db_name" {
  name  = "DB_NAME_AROCORDINS"
  type  = "String"
  value = var.arocordins_db_name
}


resource "aws_ssm_parameter" "s3_bucket" {
  name  = "S3_BUCKET_AROCORD_INSIGHTS"
  type  = "String"
  value = var.document_bucket
}

# Use SecureString for API keys (better than CDK version)
resource "aws_ssm_parameter" "openai_key" {
  name  = "OPENAI_API_KEY"
  type  = "SecureString"
  value = var.openai_api_key
}

# Use SecureString for Zoho keys 
resource "aws_ssm_parameter" "zoho_notifier_param" {
  name  = "ZOHO_NOTIFIER_SECRET_NAME"
  type  = "SecureString"
  value = var.zoho_notifier
}
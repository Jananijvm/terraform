environment = "prod"
purpose     = "insights"

artifact_bucket    = "dev-mghealth-artifact-ap-southeast-1"
artifact_base_path = "arocordinsights-standalone/arocord-summarizer-api/develop/14"
layer_core_key     = "layers/layer-core-arocord-insight-aisummarizer/python.zip"
layer_pdf_key      = "layers/layer-pdf-arocord-insight-aisummarizer/python.zip"
layer_numpy_key    = "layers/numpy_scipy/python.zip"
layer_openai_key   = "layers/openai-layer/python.zip"
layer_pymysql_key  = "layers/pymysql/python.zip"
layer_requests_key = "layers/requests-toolbelt/python.zip"
layer_jose_key     = "layers/python-jose/python.zip"

vpc_name    = "core"
vpc_cidr    = "10.0.0.0/16"

enable_dns_support   = true
enable_dns_hostnames = true

rds_port    = 3306
ssh_port    = 22
aurora_port = 5432
az_count = 2


db_identifier = "arocord"
db_name       = "arocord"
engine_version = "8.0.45"

instance_class = "t4g.medium"

storage_gb     = 100
max_storage_gb = 1000

multi_az            = true
publicly_accessible = false
master_username = "prod_arocordhims"
secret_rotation_schedule = "cron(0 22 ? * SAT *)"
backup_retention_days = 7
copy_tags_to_snapshot = true

# S3 (mapped from .env)

s3_versioned     = false
s3_removal_policy = "destroy"

s3_cors_rules = [
  {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [
            "Content-Disposition",
            "ETag"
        ],
        "MaxAgeSeconds": 3600
    }
]



cognito_user_pool_name  = "arocordins-user-pool"
cognito_app_client_name = "arocordins"

cognito_refresh_token_days = 180
cognito_access_token_days  = 1
cognito_id_token_days      = 1
cognito_session_minutes    = 3

cognito_user_groups = ["arocordins_Admin","arocordins_CareTaker","arocordins_Doctor","arocordins_superAdmin","arocordins_frontDesk","arocordins_labTechnician","arocordins_pharmacist","arocordins_Staff"]

cognito_callback_urls = ["https://d84l1y8p4kdic.cloudfront.net"]
cognito_logout_urls   = ["https://d84l1y8p4kdic.cloudfront.net"]

cognito_domain_prefix = "arocordins-dev"

cognito_email_subject = "Verify Your Email Address for AroCord"

cognito_email_html = <<EOF
<!DOCTYPE html><html><body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'><div style='max-width: 600px; background: #fff; padding: 20px; border-radius: 6px; margin: auto; box-shadow: 0 2px 8px rgba(0,0,0,0.1);'><h2 style='color: #6a0dad;'>Welcome to AroCord!</h2><p>Hi there!</p><p>Thank you for signing up. To get started, please verify your email by clicking the link below:</p><p style='word-break: break-all; text-align: center; margin: 20px 0;'>{##Verify Email##}</p><p>If you didn’t sign up for AroCord Insights - AI Summarizer, you can safely ignore this email.</p><p>Warm regards,<br>MG Health Tech Team</p></div></body></html>
EOF

# AI SUMMARISER PURPOSE

# AURORA_DB_IDENTIFIER     = "arocord-insight-embeddings"
# AURORA_WRITER_IDENTIFIER = "arocord-insight-embeddings-instance"
# AURORA_ENGINE_VERSION    = "17.4"
# AURORA_PORT              = 5432

# AURORA_DB_USERNAME = "arocordInsights"

# AURORA_BACKUP_RETENTION_DAYS = 7

# AURORA_MIN_ACU = 0.5
# AURORA_MAX_ACU = 2

# AURORA_REMOVAL_POLICY = "destroy"

rds_db_name     = "arocord"
arocordins_db_name = "arocordInsightsSeparate"


app_client_id_arocord_app = "<arocord_app_app_client_id>"
user_pool_id_arocord_app  = "<arocord_app_user_pool_id>"
from_email                = "<set_email>"

aggregated_cache_table    = "aggregated_usage_cache"
bulletin_dynamodb_enabled = "true"
clinic_id                 = "my-clinic"
comprehend_region         = "ap-southeast-2"
interval_limit            = "5.00"
monthly_limit             = "20.00"
openai_api_key            = "<replace-with-real-key>"
openai_api_key_1          = "<replace-with-real-key>"
openai_api_key_2          = "<replace-with-real-key>"
openai_api_key_3          = "<replace-with-real-key>"
openai_api_key_4          = "<replace-with-real-key>"
summary_status_table      = "summary_status"
usage_records_table       = "usage_records"
warning_events_table      = "warning_events"
deepgram_api_key          = "<your_deepgram_api_key>"
audio_bucket              = "arocord-hims-transcriber-audio"
document_bucket           = "arocord-insights-standalone"


# Deploy Bucket
s3_deploy_bucket = "insights-arocord"
patient_api_base = "<you_patient_api_base>"
api_keys = {
  sarvamApiKey   = "<your_sarvam_api_key>"
  openaiApiKey   = "<your_openai_api_key>"
  deepgramApiKey = "<your_deepgram_api_key>"
}

arocord_app_region = "<your_region>"

audit_table_name  = "arocord-hims-audit-logs"

bus_name  = "arocord-hims-audit-bus"
rule_name = "audit-rule"

zoho_notifier ={
    client_id = "<your_zoho_client_id>"
    client_secret = "<your_zoho_client_secret>"
    refresh_token = "<your_zoho_refresh_token>"
    team_id = "<your_zoho_team_id>"
    project_id = "<your_zoho_project_id>"
    sprint_id = "<your_zoho_sprint_id>"
    bug_type_id = "<your_zoho_bug_type_id>"
    prio_high_id = "<your_zoho_prio_high_id>"
    prio_med_id = "<your_zoho_prio_med_id>"
}

zoho_accounts_url = "https://accounts.zoho.in/oauth/v2/token"
zoho_api_url = "https://sprintsapi.zoho.in/zsapi"

sns_topic_name = "arocord-alerts-dev"
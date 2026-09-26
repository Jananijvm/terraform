data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "apigateway_full" {
  arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

data "aws_iam_policy" "dynamodb_full" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "s3_full" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "sqs_full" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

data "aws_iam_policy" "appsync_admin" {
  arn = "arn:aws:iam::aws:policy/AWSAppSyncAdministrator"
}

module "iam" {
  source = "./modules/iam"
  audio_bucket_name = module.s3.audio_bucket_name
  document_bucket_name = module.s3.document_bucket_name 
  sqs_queue_name = "arocord-document-summarizer-queue"
  api_secret_name = module.secrets.secret_name

  cognito_user_pool_arns = [
    "arn:aws:cognito-idp:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:userpool/${module.cognito.user_pool_id}"
  ]

  appsync_api_id = module.appsync.appsync_api_id
  transcript_appsync_api_id = module.appsync.transcript_appsync_api_id
  cognito_user_pool_id = module.cognito.user_pool_id
  transcription_lambda_arn = module.lambda.lambda_arns["transcription"]
}

module "vpc" {
  source = "./modules/vpc"

  environment = var.environment
  purpose     = var.purpose

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  rds_port    = var.rds_port
  ssh_port    = var.ssh_port
  aurora_port = var.aurora_port
  az_count = var.az_count
}


module "rds" {
  source = "./modules/rds"

  environment = var.environment
  purpose     = var.purpose

  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_security_group_id = module.vpc.rds_sg_id

  db_identifier = var.db_identifier
  db_name       = var.db_name
  engine_version = var.engine_version
  instance_class = var.instance_class

  storage_gb      = var.storage_gb
  max_storage_gb  = var.max_storage_gb

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible
  master_username        = var.master_username
  backup_retention_days  = var.backup_retention_days
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  secret_rotation_schedule = var.secret_rotation_schedule
  providers = {
    aws        = aws
    aws.backup = aws.backup
  }
}


module "s3" {
  source = "./modules/s3"

  environment = var.environment
  purpose     = var.purpose

  document_bucket_base   = var.document_bucket
  
  audio_bucket_base  = var.audio_bucket
  deploy_bucket_base = var.s3_deploy_bucket 
  versioned      = var.s3_versioned
  removal_policy = var.s3_removal_policy
  cors_rules     = var.s3_cors_rules
}



module "cognito" {
  source = "./modules/cognito"

  environment = var.environment
  purpose     = var.purpose

  user_pool_name  = var.cognito_user_pool_name
  app_client_name = var.cognito_app_client_name

  refresh_token_days = var.cognito_refresh_token_days
  access_token_days  = var.cognito_access_token_days
  id_token_days      = var.cognito_id_token_days
  session_minutes    = var.cognito_session_minutes

  user_groups  = var.cognito_user_groups
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  domain_prefix = var.cognito_domain_prefix

  email_subject = var.cognito_email_subject
  email_html    = var.cognito_email_html
    audio_bucket_name = module.s3.audio_bucket_name
    document_bucket_name = module.s3.document_bucket_name 
}

# AI SUMMARISER PURPOSE

/*
module "aurora" {
  source = "./modules/aurora"

  environment = var.environment
  purpose     = var.purpose

  db_identifier       = var.AURORA_DB_IDENTIFIER
  writer_identifier   = var.AURORA_WRITER_IDENTIFIER
  engine_version      = var.AURORA_ENGINE_VERSION
  port                = var.AURORA_PORT

  db_username = var.AURORA_DB_USERNAME

  backup_retention_days = var.AURORA_BACKUP_RETENTION_DAYS

  min_acu = var.AURORA_MIN_ACU
  max_acu = var.AURORA_MAX_ACU

  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.vpc.embeddings_sg_id

  monitoring_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rds-monitoring-role"


  removal_policy = var.AURORA_REMOVAL_POLICY
}
*/

module "parameter_store" {
  source = "./modules/parameterstore"

  db_secret_name = module.rds.master_secret_arn
  db_host        = module.rds.db_host
  document_bucket = module.s3.document_bucket_name
arocordins_db_name=var.arocordins_db_name
  openai_api_key = var.openai_api_key
  zoho_notifier= module.secrets.zoho_notifier_secret_name
}


module "lambda_layers" {
  source = "./modules/lambda_layers"


  artifact_bucket    = var.artifact_bucket
  artifact_base_path = var.artifact_base_path

  layer_core_key     = var.layer_core_key
  layer_pdf_key      = var.layer_pdf_key
  layer_numpy_key    = var.layer_numpy_key
  layer_openai_key   = var.layer_openai_key
  layer_pymysql_key  = var.layer_pymysql_key
  layer_requests_key = var.layer_requests_key
  layer_jose_key     = var.layer_jose_key
}

# AI SUMMARISER PURPOSE

module "lambda" {
  source = "./modules/lambda"

  environment = var.environment
  purpose     = var.purpose

  artifact_bucket    = var.artifact_bucket
  artifact_base_path = var.artifact_base_path

  private_subnet_ids = module.vpc.private_subnet_ids
  lambda_sg_id       = module.vpc.lambda_sg_id
  rds_sg_id          = module.vpc.rds_sg_id

  document_bucket = module.s3.document_bucket_name

  db_secret_arn  = module.rds.master_secret_arn
 # db_cluster_arn = module.aurora.cluster_arn

  layer_arns = module.lambda_layers.layer_arns

  app_client_id_arocord_app = var.app_client_id_arocord_app
  user_pool_id_arocord_app  = var.user_pool_id_arocord_app
  cognito_user_pool_id      = module.cognito.user_pool_id
  cognito_app_client_id     = module.cognito.app_client_id
  from_email                = var.from_email

  aggregated_cache_table    = var.aggregated_cache_table
  appsync_api_url           = module.appsync.appsync_api_url
  bulletin_dynamodb_enabled = var.bulletin_dynamodb_enabled
  clinic_id                 = var.clinic_id
  comprehend_region         = var.comprehend_region
  interval_limit            = var.interval_limit
  monthly_limit             = var.monthly_limit
  openai_api_key            = var.openai_api_key
  openai_api_key_1          = var.openai_api_key_1
  openai_api_key_2          = var.openai_api_key_2
  openai_api_key_3          = var.openai_api_key_3
  openai_api_key_4          = var.openai_api_key_4
 # summarizer_queue_url      = module.sqs.summariser_queue_url
  email_queue_url           = module.sqs.email_queue_url
  soap_queue_url            = module.sqs.soap_queue_url
  refine_queue_url          = module.sqs.refine_queue_url
  transcribe_queue_url      = module.sqs.transcribe_queue_url
  summary_status_table      = var.summary_status_table
  usage_records_table       = var.usage_records_table
  warning_events_table      = var.warning_events_table
  audio_bucket              = module.s3.audio_bucket_name
  deepgram_api_key          = var.deepgram_api_key
  zoho_notifier_parameter_name = module.parameter_store.zoho_notifier_parameter_name
  zoho_accounts_url = var.zoho_accounts_url
  zoho_api_url = var.zoho_api_url
  zoho_notifier_sns_topic_arn = module.sns.topic_arn

  policy_arns = {
    apigateway_full = data.aws_iam_policy.apigateway_full.arn
    dynamodb_full = data.aws_iam_policy.dynamodb_full.arn
    s3_full = data.aws_iam_policy.s3_full.arn
    sqs_full = data.aws_iam_policy.sqs_full.arn
    appsync_admin = data.aws_iam_policy.appsync_admin.arn
    lambda_appsync_refinenotes = module.iam.lambda_appsync_refinenotes_policy_arn
    lambda_appsync_soap_notes = module.iam.lambda_appsync_soapnotes_policy_arn
    lambda_appsync_email_template = module.iam.lambda_appsync_email_template_arn
    lambda_appsync_transcript = module.iam.lambda_appsync_transcript_arn
    lambda_role = module.iam.lambda_role_policy_arn
    rds_connectivity = module.iam.rds_connectivity_policy_arn
    ssm_secrets_and_eventbridge_audit = module.iam.ssm_secrets_and_eventbridge_audit_policy_arn
    ec2_network_interface = module.iam.ec2_network_interface_policy_arn
    s3_artifacts_access = module.iam.s3_artifacts_access_policy_arn
    rds_data_api = module.iam.rds_data_api_policy_arn
    ses_email_access = module.iam.ses_email_access_policy_arn
    sqs_send = module.iam.sqs_send_policy_arn
    aisummarizer_manager = module.iam.aisummarizer_manager_policy_arn
    zoho_secret_access = module.iam.zoho_secret_access_policy_arn
    lambda_logging = module.iam.lambda_logging_policy_arn
    worker_lambda = module.iam.worker_lambda_policy_arn
    arocord_insights_api_keys = module.iam.arocord_insights_api_keys_policy_arn
    arocord_insights_cognito = module.iam.arocord_insights_cognito_policy_arn
    dynamodb_audit = module.iam.dynamodb_audit_policy_arn
    zoho_notifier=module.iam.zoho_notifier_policy_arn
  }

arocord_app_region =var.arocord_app_region
  account_id = var.account_id
  region     = var.region
  image_tag  = var.image_tag
  transcript_appsync_api_url = module.appsync.transcript_appsync_api_url
  transcript_jobs_table_name = module.dynamodb.transcript_jobs_table_name
  api_secret_keys = module.secrets.secret_name
  patient_api_base =var.patient_api_base
}

module "api_gateway" {
  source = "./modules/api_gateway"

  lambda_invoke_arns    = module.lambda.lambda_invoke_arns
  lambda_function_names = module.lambda.lambda_function_names
  lambda_arns           = module.lambda.lambda_arns
  user_pool_id          = module.cognito.user_pool_id
  environment           = var.environment
}



module "appsync" {
  source = "./modules/appsync"
  user_pool_id                      = module.cognito.user_pool_id
  transcription_lambda_arn          = module.lambda.lambda_arns["transcription"]
  transcription_lambda_role         = module.lambda.lambda_roles["transcription"]
  appsync_lambda_invoke_policy_arn  = module.iam.appsync_lambda_invoke_policy_arn
}

# AI SUMMARISER PURPOSE

module "sqs" {
  source = "./modules/sqs"
  queue_name = "arocord-document-summarizer-queue"
 # aisummarizer_arn = module.lambda.lambda_arns["aisummarizer"]
  soap_email_template_worker_arn = module.lambda.soap_email_template_worker_arn
  soap_refine_worker_arn = module.lambda.soap_refine_worker_arn
  transcription_worker_arn= module.lambda.transcription_worker_arn
  soap_worker_arn = module.lambda.soap_worker_arn
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id
}

module "dynamodb" {
  source = "./modules/dynamodb"
  environment      = var.environment
  purpose          = var.purpose
  audit_table_name = var.audit_table_name
}


module "ecr" {
  source = "./modules/ecr"
}

module "secrets" {
  source = "./modules/secrets_manager"

  api_keys = var.api_keys
  zoho_notifier = var.zoho_notifier

  depends_on = [module.vpc]
}

module "eventbridge" {
  source = "./modules/eventbridge"

  bus_name  = var.bus_name
  rule_name = var.rule_name

  lambda_arn  = module.lambda.lambda_arns["auditlogger"]
  lambda_name = module.lambda.lambda_function_names["auditlogger"]
}

module "sns" {
  source = "./modules/sns"

  topic_name = var.sns_topic_name
  zoho_notifier_lambda_arn = module.lambda.lambda_arns["zohoNotifier"]
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch_alarms"

  environment    = var.environment
  sns_topic_arn  = module.sns.topic_arn
  function_names = values(module.lambda.lambda_function_names)
}
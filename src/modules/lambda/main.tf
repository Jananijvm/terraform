data "aws_region" "current" {}

resource "aws_iam_role" "lambda_role" {
  for_each = local.lambdas

  name = substr("${each.value.name}-${data.aws_region.current.id}-role", 0, 64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = each.key == "transcription" ? [
            "lambda.amazonaws.com",
            "appsync.amazonaws.com"
          ] : [
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}




locals {
  lambda_policies = {
    signup = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "arocord_insights_cognito",
      "ssm_secrets_and_eventbridge_audit"
    ]
    login = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    dashboard = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    patient = [
      "apigateway_full",
      "s3_full",
      "rds_connectivity",
      "ec2_network_interface",
      "s3_artifacts_access",
      "rds_data_api",
      "ses_email_access",
      "sqs_send",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    doctor = [
      "apigateway_full",
      "s3_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    caretaker = [
      "apigateway_full",
      "s3_full",
      "rds_connectivity",
      "ec2_network_interface",
      "zoho_secret_access",
      "lambda_logging",
      "arocord_insights_cognito",
      "ssm_secrets_and_eventbridge_audit"
    ]
    clinicinfo = [
      "apigateway_full",
      "s3_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    aisummarizer = [
      "apigateway_full",
      "dynamodb_full",
      "s3_full",
      "aisummarizer_manager",
      "ec2_network_interface",
      "lambda_logging",
    ]
    insightsauth = [
      "s3_full",
      "ec2_network_interface",
      "lambda_logging",
      
    ]
    appinsights = [
      "apigateway_full",
      "rds_connectivity",
      "ses_email_access",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    refinenotes = [
      "dynamodb_full",
      "s3_full",
      "sqs_full",
      "appsync_admin",
      "lambda_appsync_refinenotes",
      "lambda_role",
      "lambda_logging",
      
    ]
    soapemailtemplate = [
      "dynamodb_full",
      "s3_full",
      "sqs_full",
      "appsync_admin",
      "lambda_appsync_email_template",
      "lambda_role",
      "lambda_logging",
   
    ]
    soapnotes = [
      "dynamodb_full",
      "s3_full",
      "sqs_full",
      "appsync_admin",
      "lambda_appsync_soap_notes",
      "lambda_role",
      "lambda_logging",
      "ec2_network_interface",
     
    ]
    transcription = [
      "dynamodb_full",
      "s3_full",
      "sqs_full",
      "appsync_admin",
      "lambda_appsync_transcript",
      "arocord_insights_api_keys",
      "lambda_role",
      "lambda_logging",
     
    ]
    labTechnician = [
      "apigateway_full",
      "rds_connectivity",
      "lambda_logging",
      "ec2_network_interface",
      "ssm_secrets_and_eventbridge_audit"
    ]
    auditlogger = [
      "apigateway_full",
      "rds_connectivity",
      "ssm_secrets_and_eventbridge_audit",
      "ec2_network_interface",
      "lambda_logging",
      "dynamodb_audit",
     
    ]
    pharmacy = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    inpatient = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    discharge = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    wardsbeds = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    invoiceRecords = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    paymentBilling = [
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]
    
    billingModule=[
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]

    billingServices=[
      "apigateway_full",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
      "ssm_secrets_and_eventbridge_audit"
    ]

    zohoNotifier=[
      "lambda_logging",
      "zoho_notifier"
    ]

    adminPanel=[
      "apigateway_full",
      "ssm_secrets_and_eventbridge_audit",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
    ]
    arocordinsightsAuth=[
       "apigateway_full",
      "ssm_secrets_and_eventbridge_audit",
      "rds_connectivity",
      "ec2_network_interface",
      "lambda_logging",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policies" {
  for_each = {
    for item in flatten([
      for lambda_key, policy_keys in local.lambda_policies : [
        for policy_key in policy_keys : {
          lambda_key = lambda_key
          policy_key = policy_key
        }
      ]
    ]) : "${item.lambda_key}-${item.policy_key}" => item
  }

  role       = aws_iam_role.lambda_role[each.value.lambda_key].name
  policy_arn = var.policy_arns[each.value.policy_key]

}




locals {
  lambd\\\\as = {

    signup = {
      name    = "arocord-insights-standalone-signup"
      handler = "arocordinsights-standalone-signup.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-signup.zip"
      layers  = ["pymysql"]
      signup_env = true
    }

    login = {
      name    = "arocord-insights-standalone-login"
      handler = "arocordinsights-standalone-login.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-login.zip"
      layers  = ["pymysql"]
    }

    dashboard = {
      name    = "arocord-insights-standalone-dashboard"
      handler = "arocordinsights-standalone-dashboard.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-dashboard.zip"
      layers  = ["pymysql"]
    }

    patient = {
      name    = "arocord-insights-standalone-patient"
      handler = "arocordinsights_standalone_patient.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-patient.zip"
      layers  = ["pymysql", "requests"]
      patient_env = true
    }

    doctor = {
      name    = "arocord-insights-standalone-doctor"
      handler = "arocordinsights-standalone-doctor.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-doctor.zip"
      layers  = ["pymysql", "requests"]
    }

    caretaker = {
      name    = "arocord-insights-standalone-caretaker"
      handler = "arocord-insights-standalone-caretaker.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-caretaker.zip"
      layers  = ["pymysql", "requests"]
    
    }

    clinicinfo = {
      name    = "arocord-insights-standalone-clinic-info"
      handler = "arocordinsights_standalone_clinicinfo.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-clinicinfo.zip"
      layers  = ["pymysql", "requests"]
    }

    aisummarizer = {
      name    = "arocord-insights-standalone-aisummarizer"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-aisummarizer.zip"
      layers  = ["pymysql", "requests", "core", "pdf"]
      ai_env  = true
    }

   insightsauth  = {
      name    = "arocord-app-insights-auth"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-app-insights-auth.zip"
      layers  = ["jose"]
      cognito_env = true
    }

    appinsights = {
      name    = "arocord-app-insights"
      handler = "arocord-app-insights.lambda_handler"
      key     = "lambda-functions/arocord-app-insights.zip"
      layers  = ["pymysql", "requests"]
      ses_env = true
    }

    refinenotes = {
      name    = "arocord-insights-standalone-refine-notes"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-refine-notes.zip"
      layers  = []
      refine_env = true
    }

    soapemailtemplate = {
      name    = "arocord-insights-standalone-soap-email-template"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-soap-email-template.zip"
      layers  = []
      soap_env = true
    }

    soapnotes = {
      name    = "arocord-insights-standalone-soap-notes"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-soap-notes.zip"
      layers  = []
      soap_env = true
    }

    transcription = {
      name    = "arocord-insights-standalone-transcription"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-transcription.zip"
      layers  = []
      transcription_env = true
    }

    labTechnician = {
      name = "arocord-insights-standalone-lab"
      handler = "arocord-insights-standalone-lab.lambda_handler"
      key = "lambda-functions/arocord-insights-standalone-lab.zip"
      layers  = ["pymysql"]
    }
    
    auditlogger = {
      name    = "arocord-hims-audit-logger"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-hims-audit-logger.zip"
      layers  = ["pymysql"]
    }
    pharmacy = {
      name    = "arocord-insights-standalone-pharmacy"
      handler = "arocord-insights-standalone-pharmacy.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-pharmacy.zip"
      layers  = ["pymysql"]
    }
    inpatient = {
      name    = "arocord-insights-standalone-inpatient"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-inpatients.zip"
      layers  = ["pymysql"]
      signup_env = true
    }
    discharge = {
      name    = "arocord-insights-standalone-discharge"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-discharge.zip"
      layers  = ["pymysql"]
      signup_env = true
    }
    wardsbeds = {
      name    = "arocord-insights-standalone-wards-beds"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-ward-beds.zip"
      layers  = ["pymysql"]
      signup_env = true
    }
    invoiceRecords = {
      name    = "arocord-insights-standalone-invoiceRecords"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-invoiceRecords.zip"
      layers  = ["pymysql"]
    }
    paymentBilling ={
      name    = "arocord-insights-standalone-paymentBilling"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-paymentBilling.zip"
      layers  = ["pymysql"]

    }
    billingModule = {
      name    = "arocord-insights-standalone-billingModule"
      handler = "lambda_handler.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-billingModule.zip"
      layers  = ["pymysql"]
    } 
    billingServices={
      name    = "arocord-insights-standalone-billingServices"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-billingServices.zip"
      layers  = ["pymysql"]
    }
    zohoNotifier ={
      name    = "arocord-insights-zoho-notifier"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-zoho-notifier.zip"
      layers = []
      zoho_notify_env = true
    }

    adminPanel ={
      name    = "arocord-insights-standalone-adminPanel"
      handler = "arocord-insights-standalone-adminPanel.lambda_handler"
      key     = "lambda-functions/arocord-insights-standalone-adminPanel.zip"
      layers  = ["pymysql"]

    }
    arocordinsightsAuth={
      name    = "arocord-insights-auth"
      handler = "lambda_function.lambda_handler"
      key     = "lambda-functions/arocord-insights-auth.zip"
      layers  = ["pymysql","jose"]
      arocordinsightsAuthEnv = true
    }
  
  }
}


locals {
  layer_lookup = {
    pymysql  = var.layer_arns["pymysql"]
    requests = var.layer_arns["requests"]
    core     = var.layer_arns["core"]
    pdf      = var.layer_arns["pdf"]
    numpy    = var.layer_arns["numpy"]
    openai   = var.layer_arns["openai"]
    jose     =var.layer_arns["jose"]
  }
}

resource "aws_lambda_function" "this" {
  for_each = local.lambdas

  function_name = "${each.value.name}-${data.aws_region.current.id}"
  role          = aws_iam_role.lambda_role[each.key].arn
  handler       = each.value.handler
  runtime       = "python3.13"
  memory_size = lookup({
  refinenotes       = 3000
  soapemailtemplate = 2972
  soapnotes         = 3000
  transcription     = 3000
  aisummarizer      = 3000
  }, each.key, 128)
  timeout = 900
 ephemeral_storage {
  size = contains(["refinenotes", "soapemailtemplate", "soapnotes"], each.key) ? 3072 : 512
 }
  s3_bucket = var.artifact_bucket
  s3_key = "${var.artifact_base_path}/${each.value.key}"

  dynamic "vpc_config" {
  for_each = contains(["refinenotes", "soapemailtemplate", "transcription","zohoNotifier"], each.key) ? [] : [1]

  content {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
 }

  layers = [
    for l in each.value.layers :
    local.layer_lookup[l]
  ]
  
# AI SUMMARISER PURPOSE

  environment {
    variables = lookup(each.value, "transcription_env", false) ? {
      TRANSCRIPT_JOBS_TABLE = "TranscriptJobs"
      AUDIO_BUCKET          = var.audio_bucket
      TRANSCRIBE_QUEUE_URL  = var.transcribe_queue_url
    } : lookup(each.value, "soap_env", false) && each.key == "soapemailtemplate" ? {
      TRANSCRIPT_JOBS_TABLE = "TranscriptJobs"
      AUDIO_BUCKET          = var.audio_bucket
      EMAIL_QUEUE_URL       = var.email_queue_url
    } : lookup(each.value, "soap_env", false) ? {
      TRANSCRIPT_JOBS_TABLE = "TranscriptJobs"
      AUDIO_BUCKET          = var.audio_bucket
      SOAP_QUEUE_URL        = var.soap_queue_url
    } : lookup(each.value, "refine_env", false) ? {
      TRANSCRIPT_JOBS_TABLE = "TranscriptJobs"
      AUDIO_BUCKET          = var.audio_bucket
      REFINE_QUEUE_URL      = var.refine_queue_url
    } : lookup(each.value, "ai_env", false) ? {
      AGGREGATED_CACHE_TABLE          = var.aggregated_cache_table
      APPSYNC_API_URL                 = var.appsync_api_url
      AUTO_BOOTSTRAP_SPACY            = "false"
      BULLETIN_DYNAMODB_ENABLED       = var.bulletin_dynamodb_enabled
      CLINIC_ID                       = var.clinic_id
      COMPREHEND_CHUNKING_ENABLED     = "true"
      COMPREHEND_CHUNK_OVERLAP_CHARS  = "500"
      COMPREHEND_REGION               = var.comprehend_region
     # DB_CLUSTER_ARN                  = var.db_cluster_arn
      DB_NAME                         = "arocord_embeddings"
      DYNAMODB_REGION                 = data.aws_region.current.id
      ENABLE_EMBEDDINGS               = "true"
      INTERVAL_LIMIT                  = var.interval_limit
      MAX_CONCURRENT_DOCS             = "20"
      MODEL_S3_BUCKET                 = var.document_bucket
      MODEL_S3_KEY                    = "models/spacy/v1/spacy_model.tar.gz"
      MONTHLY_LIMIT                   = var.monthly_limit
      OPENAI_API_KEY                  = var.openai_api_key
      OPENAI_API_KEY_1                = var.openai_api_key_1
      OPENAI_API_KEY_2                = var.openai_api_key_2
      OPENAI_API_KEY_3                = var.openai_api_key_3
      OPENAI_API_KEY_4                = var.openai_api_key_4
      S3_BUCKET                       = var.document_bucket
      S3_BUCKET_PATIENT_REPORTS       = var.document_bucket
      S3_REGION                       = data.aws_region.current.id
      SECRET_ARN                      = var.db_secret_arn
      SINGLE_CALL_MAX_TOKENS          = "3000"
     # SUMMARIZER_QUEUE_URL            = var.summarizer_queue_url
      SUMMARY_STATUS_TABLE            = var.summary_status_table
      USAGE_RECORDS_TABLE             = var.usage_records_table
      USE_COMPREHEND_MEDICAL          = "true"
      WARNING_EVENTS_TABLE            = var.warning_events_table
      WHEELS_S3_KEY                   = "spacy-wheels.zip"
    } : lookup(each.value, "ses_env", false) ? {
      FROM_EMAIL = var.from_email
      SES_REGION = data.aws_region.current.id
      S3_REGION = data.aws_region.current.id
      S3_BUCKET_NAME=  var.audio_bucket
    } : lookup(each.value, "signup_env", false) ? {
       COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    } : lookup(each.value, "cognito_env", false) ? {
      APP_CLIENT_ID_AROCORD_APP      = var.app_client_id_arocord_app
      APP_CLIENT_ID_AROCORD_INSIGHTS = var.cognito_app_client_id
      USER_POOL_ID_AROCORD_APP       = var.user_pool_id_arocord_app
      USER_POOL_ID_AROCORD_INSIGHTS  = var.cognito_user_pool_id
      AROCORD_APP_REGION             = var.arocord_app_region
      AROCORD_INSIGHTS_REGION        = data.aws_region.current.id
    } : lookup(each.value, "patient_env", false) ? {
      AUDIO_BUCKET = var.audio_bucket
      S3_BUCKET = var.document_bucket
      DEEPGRAM_API_KEY   = var.deepgram_api_key
      SES_REGION         = data.aws_region.current.id
      SES_SENDER_EMAIL   = var.from_email
    }:lookup(each.value, "arocordinsightsAuthEnv", false)?{
        APP_CLIENT_ID_AROCORD_INSIGHTS = var.cognito_app_client_id
        AROCORD_INSIGHTS_REGION        = data.aws_region.current.id
        USER_POOL_ID_AROCORD_INSIGHTS  = var.cognito_user_pool_id

    } : lookup(each.value, "zoho_notify_env", false) ? {
      DEPLOY_ENV = var.environment
      ZOHO_ACCOUNTS_URL = var.zoho_accounts_url
      ZOHO_API_BASE_URL   = var.zoho_api_url
      ZOHO_SECRET_NAME         = var.zoho_notifier_parameter_name
    } : each.key == "caretaker" ? {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      S3_BUCKET = var.document_bucket
      S3_REGION = data.aws_region.current.id
    } : each.key == "clinicinfo" ? {
      S3_BUCKET = var.document_bucket
      S3_REGION = data.aws_region.current.name
    } : {}
  }

   lifecycle {
    ignore_changes = [
      environment[0].variables["OPENAI_API_KEY"],
      environment[0].variables["OPENAI_API_KEY_1"],
      environment[0].variables["OPENAI_API_KEY_2"],
      environment[0].variables["OPENAI_API_KEY_3"],
      environment[0].variables["OPENAI_API_KEY_4"],
      environment[0].variables["DEEPGRAM_API_KEY"],
      environment[0].variables["APP_CLIENT_ID_AROCORD_APP"],
      environment[0].variables["APP_CLIENT_ID_AROCORD_INSIGHTS"],
      environment[0].variables["FROM_EMAIL"],
      environment[0].variables["SES_SENDER_EMAIL"],
      environment[0].variables["USER_POOL_ID_AROCORD_APP"],
      environment[0].variables["AROCORD_APP_REGION"]
    ]
  }
}



# 1. SOAP EMAIL TEMPLATE

resource "aws_lambda_function" "soap_email_template_worker" {

  function_name = substr("arocord-insights-standalone-email-template-worker-${var.region}", 0, 64)
  role          = aws_iam_role.soap_email_template_worker_role.arn

  package_type = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/arocord-insights-standalone-soap-email-template-worker-lambda-${var.region}:${var.image_tag}"

  architectures = ["x86_64"]

  memory_size = 2999
  timeout     = 900

  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      APPSYNC_URL           = var.transcript_appsync_api_url
      AUDIO_BUCKET          = var.audio_bucket
      TRANSCRIPT_JOBS_TABLE = var.transcript_jobs_table_name
      API_SECRET_NAME = var.api_secret_keys
    }
  }
}


# 2. SOAP REFINE WORKER

resource "aws_lambda_function" "soap_refine_worker" {

  function_name = substr("arocord-insights-standalone-soap-refine-worker-${var.region}", 0, 64)
  role          = aws_iam_role.refine_worker_role.arn

  package_type = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/arocord-insights-standalone-soap-refine-worker-lambda-${var.region}:${var.image_tag}"

  architectures = ["x86_64"]

  memory_size = 3000
  timeout     = 900

  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      APPSYNC_URL           = var.transcript_appsync_api_url
      AUDIO_BUCKET          = var.audio_bucket
      TRANSCRIPT_JOBS_TABLE = var.transcript_jobs_table_name
      API_SECRET_NAME = var.api_secret_keys
    }
  }
}


# 3. TRANSCRIPTION WORKER

resource "aws_lambda_function" "transcription_worker" {

  function_name = substr("arocord-insights-standalone-transcription-worker-${var.region}", 0, 64)
  role          = aws_iam_role.transcription_worker_role.arn

  package_type = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/arocord-insights-standalone-transcription-worker-lambda-${var.region}:${var.image_tag}"

  architectures = ["x86_64"]

  memory_size = 3000
  timeout     = 900

  ephemeral_storage {
    size = 3072
  }

  environment {
    variables = {
      APPSYNC_URL           = var.transcript_appsync_api_url
      AUDIO_BUCKET          = var.audio_bucket
      TRANSCRIPT_JOBS_TABLE = var.transcript_jobs_table_name
      API_SECRET_NAME = var.api_secret_keys
    }
  }
}

# 4. SOAP WORKER

resource "aws_lambda_function" "soap_worker" {

  function_name = substr("arocord-insights-standalone-soap-worker-${var.region}", 0, 64)
  role          = aws_iam_role.soap_worker_role.arn

  package_type = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/arocord-insights-standalone-soap-worker-lambda-${var.region}:${var.image_tag}"

  architectures = ["x86_64"]

  memory_size = 3000
  timeout     = 900

  ephemeral_storage {
    size = 512
  }

  #  ADD THIS BLOCK
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      APPSYNC_URL           = var.transcript_appsync_api_url
      AUDIO_BUCKET          = var.audio_bucket
      TRANSCRIPT_JOBS_TABLE = var.transcript_jobs_table_name
      API_SECRET_NAME       = var.api_secret_keys
      PATIENT_API_BASE      = var.patient_api_base
      PATIENT_LAMBDA_NAME   = "arocord-insights-standalone-patient-${data.aws_region.current.id}"
      S3_BUCKET             = var.document_bucket
    }
  }

  lifecycle {
    ignore_changes = [
      environment[0].variables["PATIENT_API_BASE"]
    ]
  }
}

# SOAP EMAIL TEMPLATE WORKER ROLE

resource "aws_iam_role" "soap_email_template_worker_role" {
  name = "arocord-insights-soap-email-template-worker-role-${data.aws_region.current.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ATTACH AWS MANAGED POLICIES

resource "aws_iam_role_policy_attachment" "soap_email_worker_sqs_queue_execution" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_lambda_full_access" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_s3_full_access" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_ecr_public_full_access" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_dynamodb_full_access" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# ATTACH CUSTOM IAM POLICIES

resource "aws_iam_role_policy_attachment" "soap_email_worker_rds_connectivity" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = var.policy_arns["rds_connectivity"]
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_ssm_secrets" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = var.policy_arns["ssm_secrets_and_eventbridge_audit"]
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_lambda_logging" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = var.policy_arns["lambda_logging"]
}

resource "aws_iam_role_policy_attachment" "soap_email_worker_worker_lambda" {
  role       = aws_iam_role.soap_email_template_worker_role.name
  policy_arn = var.policy_arns["worker_lambda"]
}



# SOAP WORKER ROLE

resource "aws_iam_role" "soap_worker_role" {
  name = "arocord-insights-soap-worker-role-${data.aws_region.current.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ATTACH AWS MANAGED POLICIES

resource "aws_iam_role_policy_attachment" "soap_worker_sqs_queue_execution" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "soap_worker_lambda_full_access" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_worker_s3_full_access" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_worker_ecr_public_full_access" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_worker_dynamodb_full_access" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "soap_worker_comprehendmedical_full_access" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendMedicalFullAccess"
}
# ATTACH CUSTOM IAM POLICIES

resource "aws_iam_role_policy_attachment" "soap_worker_rds_connectivity" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = var.policy_arns["rds_connectivity"]
}

resource "aws_iam_role_policy_attachment" "soap_worker_ssm_secrets" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = var.policy_arns["ssm_secrets_and_eventbridge_audit"]
}

resource "aws_iam_role_policy_attachment" "soap_worker_lambda_logging" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = var.policy_arns["lambda_logging"]
}

resource "aws_iam_role_policy_attachment" "soap_worker_worker_lambda" {
  role       = aws_iam_role.soap_worker_role.name
  policy_arn = var.policy_arns["worker_lambda"]
}





# TRANSCRIPTION WORKER ROLE
resource "aws_iam_role" "transcription_worker_role" {
  name = "arocord-insights-transcription-worker-role-${data.aws_region.current.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ATTACH AWS MANAGED POLICIES

resource "aws_iam_role_policy_attachment" "transcription_worker_sqs_queue_execution" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "transcription_worker_lambda_full_access" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "transcription_worker_s3_full_access" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "transcription_worker_ecr_public_full_access" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}

resource "aws_iam_role_policy_attachment" "transcription_worker_dynamodb_full_access" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


# ATTACH CUSTOM IAM POLICIES

resource "aws_iam_role_policy_attachment" "transcription_worker_rds_connectivity" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = var.policy_arns["rds_connectivity"]
}

resource "aws_iam_role_policy_attachment" "transcription_worker_ssm_secrets" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = var.policy_arns["ssm_secrets_and_eventbridge_audit"]
}

resource "aws_iam_role_policy_attachment" "transcription_worker_lambda_logging" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = var.policy_arns["lambda_logging"]
}

resource "aws_iam_role_policy_attachment" "transcription_worker_lambda" {
  role       = aws_iam_role.transcription_worker_role.name
  policy_arn = var.policy_arns["worker_lambda"]
}



# SOAP REFINE WORKER ROLE

resource "aws_iam_role" "refine_worker_role" {
  name = "arocord-insights-standalone-refine-worker-role-${data.aws_region.current.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ATTACH AWS MANAGED POLICIES

resource "aws_iam_role_policy_attachment" "refine_worker_sqs_queue_execution" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "refine_worker_lambda_full_access" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role_policy_attachment" "refine_worker_s3_full_access" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "refine_worker_ecr_public_full_access" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}

resource "aws_iam_role_policy_attachment" "refine_worker_dynamodb_full_access" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


# ATTACH CUSTOM IAM POLICIES

resource "aws_iam_role_policy_attachment" "refine-worker_rds_connectivity" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = var.policy_arns["rds_connectivity"]
}

resource "aws_iam_role_policy_attachment" "refine_worker_ssm_secrets" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = var.policy_arns["ssm_secrets_and_eventbridge_audit"]
}

resource "aws_iam_role_policy_attachment" "refine_worker_lambda_logging" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = var.policy_arns["lambda_logging"]
}

resource "aws_iam_role_policy_attachment" "refine_worker_lambda" {
  role       = aws_iam_role.refine_worker_role.name
  policy_arn = var.policy_arns["worker_lambda"]
}

resource "aws_lambda_permission" "sns_invoke_zoho_notifier" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this["zohoNotifier"].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.zoho_notifier_sns_topic_arn
}
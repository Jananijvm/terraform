data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  unique_suffix = "${local.account_id}-${local.region}"
}

# RDS CONNECTIVITY (Secrets Manager Read)

resource "aws_iam_policy" "rds_connectivity" {
  name        = "rds-connectivity-${local.unique_suffix}"
  description = "Allow Lambda to access Secrets Manager for RDS connectivity"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "LambdaSecretsManagerRole"
      Effect = "Allow"
      Action = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
    }]
  })
}

# SSM + Secrets Manager Access + EventBridge Audit (combined)

resource "aws_iam_policy" "ssm_secrets_and_eventbridge_audit" {
  name        = "ssm-secrets-and-eventbridge-audit-${local.unique_suffix}"
  description = "Allow access to SSM parameters, Secrets Manager, and EventBridge audit bus"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMSecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*",
          "arn:aws:ssm:${local.region}:${local.account_id}:parameter/*"
        ]
      },
      {
        Sid    = "EventBridgeAuditAccess"
        Effect = "Allow"
        Action = "events:PutEvents"
        Resource = "arn:aws:events:${local.region}:${local.account_id}:event-bus/arocord-hims-audit-bus"
      }
    ]
  })
}

# EC2 NETWORK INTERFACE (VPC Lambdas)
resource "aws_iam_policy" "ec2_network_interface" {
  name        = "lambda-eni-access-${local.unique_suffix}"
  description = "Allow Lambda to manage ENIs inside VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface"
      ]
      Resource = "*"
    }]
  })
}

# S3 ARTIFACT ACCESS

resource "aws_iam_policy" "s3_artifacts_access" {
  name        = "lambda-s3-artifacts-${local.unique_suffix}"
  description = "Allow Lambda to read deployment artifacts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ArtifactsRead"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.document_bucket_name}/*"
      },
      {
        Sid      = "AllowS3ArtifactsListBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.document_bucket_name}"
      }
    ]
  })
}

# RDS DATA API ACCESS

resource "aws_iam_policy" "rds_data_api" {
  name        = "rds-data-api-${local.unique_suffix}"
  description = "Allow Lambda to access Aurora via RDS Data API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRDSDataAPI"
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = "arn:aws:rds:${local.region}:${local.account_id}:cluster:arocord-insight-embeddings"
      },
      {
        Sid    = "AllowSecretsManagerForRDS"
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
      }
    ]
  })
}

# SES EMAIL ACCESS
resource "aws_iam_policy" "ses_email_access" {
  name        = "lambda-ses-email-${local.unique_suffix}"
  description = "Allow Lambda to send SES emails"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "sqs_send" {
  name        = "lambda-sqs-send-${local.unique_suffix}"
  description = "Allow Lambda to send SQS messages"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sqs:SendMessage"
      Resource = "arn:aws:sqs:${local.region}:${local.account_id}:${var.sqs_queue_name}"
    }]
  })
}

# AISUMMARIZER MANAGER POLICY (merged - comprehensive)

resource "aws_iam_policy" "aisummarizer_manager" {
  name        = "lambda-aisummarizer-manager-${local.unique_suffix}"
  description = "Comprehensive policy for AI Summarizer Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      
      {
        Sid    = "AppSyncGraphQLAccess"
        Effect = "Allow"
        Action = "appsync:GraphQL"
        Resource = "arn:aws:appsync:${local.region}:${local.account_id}:apis/${var.appsync_api_id}/*"
      },
      {
        Sid    = "ComprehendMedicalAccess"
        Effect = "Allow"
        Action = [
          "comprehendmedical:DetectEntitiesV2",
          "comprehendmedical:DetectPHI",
          "comprehendmedical:InferICD10CM",
          "comprehendmedical:InferRxNorm"
        ]
        Resource = "*"
      },
      {
        Sid    = "DynamoDBSummaryStatusWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = "arn:aws:dynamodb:${local.region}:${local.account_id}:table/summary_status"
      },
      {
        Sid    = "LambdaSelfInvoke"
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-aisummarizer-${local.region}"
      },
      {
        Sid    = "SQSReceiveAndSendMessages"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ]
        Resource = "arn:aws:sqs:${local.region}:${local.account_id}:${var.sqs_queue_name}"
      },
      {
        Sid    = "RDSConnectivity"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
      },
      {
        Sid    = "SSMSecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*",
          "arn:aws:ssm:${local.region}:${local.account_id}:parameter/*"
        ]
      },
      {
        Sid    = "EC2NetworkInterface"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ArtifactsAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.document_bucket_name}/*",
          "arn:aws:s3:::${var.document_bucket_name}"
        ]
      },
      {
        Sid    = "RDSDataAPIAccess"
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = "arn:aws:rds:${local.region}:${local.account_id}:cluster:arocord-insight-embeddings"
      }
    ]
  })
}


resource "aws_iam_policy" "zoho_secret_access" {
  name        = "zoho-secret-access-${local.unique_suffix}"
  description = "Allow read/write access to Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret"
      ]
      Resource = "*"
    }]
  })
}



resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda-logging-${local.unique_suffix}"
  description = "Allow Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_appsync_refinenotes" {
  name = "lambda-appsync-invoke-${local.unique_suffix}-refinenotes"
  description = "Allow Lambda to invoke AppSync functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-refine-notes-${local.region}"
    }]
  })
}




resource "aws_iam_policy" "lambda_appsync_soapnotes" {
  name = "lambda-appsync-invoke-${local.unique_suffix}-soapnotes"
  description = "Allow Lambda to invoke AppSync functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-soap-notes-${local.region}"
    }]
  })
}

resource "aws_iam_policy" "lambda_appsync_email_template" {
  name = "lambda-appsync-invoke-${local.unique_suffix}-email-template"
  description = "Allow Lambda to invoke AppSync functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-soap-email-template-${local.region}"
    }]
  })
}

resource "aws_iam_policy" "lambda_appsync_transcription" {
  name = "lambda-appsync-invoke-${local.unique_suffix}-transcription"
  description = "Allow Lambda to invoke AppSync functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ]
      Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-transcription-${local.region}"
    }]
  })
}

resource "aws_iam_policy" "lambda_role" {
  name        = "lambda-role-${local.unique_suffix}"
  description = "Allow Lambda DynamoDB, SQS, and S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "sqs:SendMessage",
        "s3:GetObject"
      ]
      Resource = "*"
    }]
  })
}



resource "aws_iam_policy" "arocord_insights_api_keys" {
  name        = "arocord-insights-api-keys-${local.unique_suffix}"
  description = "Allow access to Secrets Manager for arocordInsightsApiKeys"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "secretsmanager:GetSecretValue"
      Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.api_secret_name}*"
    }]
  })
}
 # WORKER LAMBDA POLICY (merged - combines 6 policies)
resource "aws_iam_policy" "worker_lambda" {
  name        = "worker-lambda-policy-${local.unique_suffix}"
  description = "Comprehensive policy for Worker Lambda - combines SQS, EC2, Lambda Invoke, AppSync, S3 Audio, and S3 Artifacts access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSqsSendToAllQueues"
        Effect = "Allow"
        Action = "sqs:SendMessage"
        Resource = [
          "arn:aws:sqs:${local.region}:${local.account_id}:SoapQueue",
          "arn:aws:sqs:${local.region}:${local.account_id}:TranscribeQueue",
          "arn:aws:sqs:${local.region}:${local.account_id}:RefineQueue",
          "arn:aws:sqs:${local.region}:${local.account_id}:EmailQueue"
        ]
      },
      {
        Sid    = "AllowEC2NetworkInterface"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowInvokePatientLambda"
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:${local.region}:${local.account_id}:function:arocord-insights-standalone-patient-${local.region}"
      },
      {
        Sid    = "AllowAppSyncGraphQL"
        Effect = "Allow"
        Action = "appsync:GraphQL"
        Resource = "arn:aws:appsync:${local.region}:${local.account_id}:apis/${var.transcript_appsync_api_id}/*"
      },
      {
        Sid    = "AllowS3AudioAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.audio_bucket_name}",
          "arn:aws:s3:::${var.audio_bucket_name}/*"
        ]
      },
      {
        Sid    = "AllowS3ArtifactsAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.document_bucket_name}",
          "arn:aws:s3:::${var.document_bucket_name}/*"
        ]
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# AROCORD INSIGHTS COGNITO POLICY
resource "aws_iam_policy" "arocord_insights_cognito" {
  name        = "arocord-insights-cognito-${local.unique_suffix}"
  description = "Allow Cognito user management operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:ListUsers",
          "cognito-idp:AdminResetUserPassword",
          "cognito-idp:AdminUpdateUserAttributes",
          "cognito-idp:AdminGetUser",
          "cognito-idp:AdminAddUserToGroup",
          "cognito-idp:AdminRemoveUserFromGroup",
          "cognito-idp:AdminDeleteUser",
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminDisableUser",
          "cognito-idp:AdminEnableUser",
          "cognito-idp:AdminListGroupsForUser"
        ]
        Resource = "arn:aws:cognito-idp:${local.region}:${local.account_id}:userpool/${var.cognito_user_pool_id}"
      }
    ]
  })
}


# APPSYNC LAMBDA INVOKE POLICY
resource "aws_iam_policy" "appsync_lambda_invoke" {
  name        = "appsync-transcript-lambda-invoke-${local.unique_suffix}"
  description = "Allow AppSync to invoke Lambda functions for transcript processing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction"
      ]
      Resource = var.transcription_lambda_arn
    }]
  })
}

# DYNAMODB AUDIT TABLE ACCESS POLICY
resource "aws_iam_policy" "dynamodb_audit" {
  name        = "dynamodb-audit-${local.unique_suffix}"
  description = "Allow Lambda to access DynamoDB audit logs table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullAuditTableAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${local.region}:${local.account_id}:table/arocord-hims-audit-logs",
          "arn:aws:dynamodb:${local.region}:${local.account_id}:table/arocord-hims-audit-logs/index/*"
        ]
      }
    ]
  })
}

# ZohoNotifierPolicy
resource "aws_iam_policy" "zoho_notifier_policy" {
  name        = "zoho-notifier-policy-${local.unique_suffix}"
  description = "ZohoNotifierPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${local.region}:${local.account_id}:parameter/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${local.region}:${local.account_id}:log-group:*:log-stream:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}
data "aws_region" "current" {}
locals{
    api_name="arocord-summariser-upload-document-status"
}


resource "aws_appsync_graphql_api" "this" {
  name                = local.api_name
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  schema = file("${path.module}/schema.graphql")

  user_pool_config {
    user_pool_id   = var.user_pool_id
    default_action = "ALLOW"
  }

  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }
}

resource "aws_appsync_datasource" "none" {
  api_id = aws_appsync_graphql_api.this.id
  name   = "NoneDataSource"
  type   = "NONE"
}
resource "aws_appsync_resolver" "update_job_status" {
  api_id      = aws_appsync_graphql_api.this.id
  type        = "Mutation"
  field       = "updateJobStatus"
  data_source = aws_appsync_datasource.none.name

  request_template = <<EOF
{
  "version": "2017-02-28",
  "payload": $util.toJson({
    "jobId": $ctx.arguments.jobId,
    "patientId": $ctx.arguments.patientId,
    "status": $ctx.arguments.status,
    "progress": $ctx.arguments.progress,
    "message": $ctx.arguments.message,
    "result": $ctx.arguments.result,
    "error": $ctx.arguments.error,
    "updatedAt": $util.time.nowISO8601()
  })
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}



########################################
# TRANSCRIPT API
########################################

resource "aws_appsync_graphql_api" "transcript_api" {
  name                = "TranscriptAPI"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  schema = file("${path.module}/transcript_schema.graphql")

  user_pool_config {
    user_pool_id   = var.user_pool_id
    default_action = "ALLOW"
  }

  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }
}


########################################
# APPSYNC ROLE TO INVOKE LAMBDA
########################################

resource "aws_iam_role" "appsync_lambda_role" {
  name = "appsync-transcript-lambda-role-${data.aws_region.current.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "appsync.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "appsync_lambda_policy" {
  role       = aws_iam_role.appsync_lambda_role.name
  policy_arn = var.appsync_lambda_invoke_policy_arn
}
########################################
# LAMBDA DATASOURCE
########################################

resource "aws_appsync_datasource" "upload_lambda_ds" {

  api_id = aws_appsync_graphql_api.transcript_api.id
  name   = "UploadLambdaDS"
  type   = "AWS_LAMBDA"

  service_role_arn = var.transcription_lambda_role

  lambda_config {
    function_arn = var.transcription_lambda_arn
  }
}


# CREATE TRANSCRIPT JOB RESOLVER

resource "aws_appsync_resolver" "create_transcript_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Mutation"
  field       = "createTranscriptJob"
  data_source = aws_appsync_datasource.upload_lambda_ds.name

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

  code = file("${path.module}/resolvers/createTranscriptJob.js")
}
########################################
# DYNAMODB DATASOURCE

resource "aws_appsync_datasource" "transcript_jobs_dynamodb" {

  api_id = aws_appsync_graphql_api.transcript_api.id
  name   = "dynamodb"
  type   = "AMAZON_DYNAMODB"

  service_role_arn = var.transcription_lambda_role

dynamodb_config {
  table_name = "TranscriptJobs"
   }
}

resource "aws_appsync_resolver" "update_transcript_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Mutation"
  field       = "updateTranscriptJob"
  data_source = aws_appsync_datasource.transcript_jobs_dynamodb.name

  request_template  = file("${path.module}/resolvers/updateTranscriptJob/request.vtl")
  response_template = file("${path.module}/resolvers/updateTranscriptJob/response.vtl")
}

resource "aws_appsync_resolver" "update_soap_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Mutation"
  field       = "updateSoapJob"
  data_source = aws_appsync_datasource.transcript_jobs_dynamodb.name

  request_template  = file("${path.module}/resolvers/updateSoapJob/request.vtl")
  response_template = file("${path.module}/resolvers/updateSoapJob/response.vtl")
}


resource "aws_appsync_resolver" "update_soap_refine_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Mutation"
  field       = "updateSoapRefineJob"
  data_source = aws_appsync_datasource.transcript_jobs_dynamodb.name

  request_template  = file("${path.module}/resolvers/update_Refine_Email_Job/request.vtl")
  response_template = file("${path.module}/resolvers/update_Refine_Email_Job/response.vtl")
}


resource "aws_appsync_resolver" "update_Email_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Mutation"
  field       = "updateEmailJob"
  data_source = aws_appsync_datasource.transcript_jobs_dynamodb.name

  request_template  = file("${path.module}/resolvers/update_Refine_Email_Job/request.vtl")
  response_template = file("${path.module}/resolvers/update_Refine_Email_Job/response.vtl")
}


resource "aws_appsync_resolver" "get_transcript_job" {

  api_id      = aws_appsync_graphql_api.transcript_api.id
  type        = "Query"
  field       = "getTranscriptJob"
  data_source = aws_appsync_datasource.transcript_jobs_dynamodb.name

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

  code = file("${path.module}/resolvers/getTranscriptJob.js")
}
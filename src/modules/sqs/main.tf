# AI SUMMARISER PURPOSE

/*
resource "aws_sqs_queue" "summarizer_queue" {
  name = var.queue_name

  max_message_size = 1048576   # 1024 KiB
  message_retention_seconds = 345600   # 4 days
  visibility_timeout_seconds = 950     # 15m 50s
}

resource "aws_sqs_queue_policy" "queue_policy" {

  queue_url = aws_sqs_queue.summarizer_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"

    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = aws_sqs_queue.summarizer_queue.arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {

  event_source_arn = aws_sqs_queue.summarizer_queue.arn
  function_name    = var.aisummarizer_arn

  batch_size = 1
  enabled    = true
}
*/

resource "aws_sqs_queue" "email_queue" {
  name = "EmailQueue"
message_retention_seconds = 345600
  max_message_size = 1048576   # 1024 KiB
  # 20 minutes visibility timeout
  visibility_timeout_seconds = 1200
}

resource "aws_sqs_queue_policy" "email_queue_policy" {

  queue_url = aws_sqs_queue.email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"

    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = aws_sqs_queue.email_queue.arn
      }
    ]
  })
}


# Attach SOAP Email Template Worker Lambda to EmailQueue SQS
resource "aws_lambda_event_source_mapping" "email_queue_trigger" {
  event_source_arn = aws_sqs_queue.email_queue.arn
  function_name    = var.soap_email_template_worker_arn 

  batch_size = 1
  enabled    = true
}

resource "aws_sqs_queue" "refine_queue" {
  name = "RefineQueue"
  message_retention_seconds = 345600
  max_message_size = 1048576   # 1024 KiB
  visibility_timeout_seconds = 1200
}

resource "aws_sqs_queue_policy" "refine_queue_policy" {

  queue_url = aws_sqs_queue.refine_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"

    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = aws_sqs_queue.refine_queue.arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "refine_queue_trigger" {
  event_source_arn = aws_sqs_queue.refine_queue.arn
  function_name    = var.soap_refine_worker_arn

  batch_size = 1
  enabled    = true
}


resource "aws_sqs_queue" "soap_queue" {
  name = "SoapQueue"

  max_message_size          = 1048576   # 1024 KiB
  message_retention_seconds = 345600    # 4 days
  visibility_timeout_seconds = 1200     # 20 minutes
}

resource "aws_sqs_queue_policy" "soap_queue_policy" {

  queue_url = aws_sqs_queue.soap_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"

    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = aws_sqs_queue.soap_queue.arn
      }
    ]
  })
}


resource "aws_lambda_event_source_mapping" "soap_queue_trigger" {
  event_source_arn = aws_sqs_queue.soap_queue.arn
  function_name    = var.soap_worker_arn

  batch_size = 1
  enabled    = true
}


resource "aws_sqs_queue" "transcribe_queue" {
  name = "TranscribeQueue"

  max_message_size           = 1048576  # 1024 KiB
  message_retention_seconds  = 345600   # 4 days
  visibility_timeout_seconds = 1200     # 20 minutes
}

resource "aws_sqs_queue_policy" "transcribe_queue_policy" {

  queue_url = aws_sqs_queue.transcribe_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "__default_policy_ID"

    Statement = [
      {
        Sid    = "__owner_statement"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }

        Action   = "SQS:*"
        Resource = aws_sqs_queue.transcribe_queue.arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "transcribe_queue_trigger" {
  event_source_arn = aws_sqs_queue.transcribe_queue.arn
  function_name    = var.transcription_worker_arn

  batch_size = 1
  enabled    = true
}

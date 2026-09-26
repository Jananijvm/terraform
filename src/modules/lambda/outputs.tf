
output "lambda_arns" {
  value = {
    signup            = aws_lambda_function.this["signup"].arn
    login             = aws_lambda_function.this["login"].arn
    dashboard         = aws_lambda_function.this["dashboard"].arn
    doctor            = aws_lambda_function.this["doctor"].arn
    patient           = aws_lambda_function.this["patient"].arn
    caretaker         = aws_lambda_function.this["caretaker"].arn
    clinicinfo        = aws_lambda_function.this["clinicinfo"].arn
    aisummarizer      = aws_lambda_function.this["aisummarizer"].arn
    insightsauth      = aws_lambda_function.this["insightsauth"].arn
    appinsights       = aws_lambda_function.this["appinsights"].arn
    refinenotes       = aws_lambda_function.this["refinenotes"].arn
    soapemailtemplate = aws_lambda_function.this["soapemailtemplate"].arn
    soapnotes         = aws_lambda_function.this["soapnotes"].arn
    transcription     = aws_lambda_function.this["transcription"].arn
    labTechnician     = aws_lambda_function.this["labTechnician"].arn
    auditlogger       = aws_lambda_function.this["auditlogger"].arn
    pharmacy          = aws_lambda_function.this["pharmacy"].arn
    inpatient          = aws_lambda_function.this["inpatient"].arn
    discharge          = aws_lambda_function.this["discharge"].arn
    wardsbeds          = aws_lambda_function.this["wardsbeds"].arn
    invoiceRecords     = aws_lambda_function.this["invoiceRecords"].arn
    paymentBilling     = aws_lambda_function.this["paymentBilling"].arn
    billingModule      = aws_lambda_function.this["billingModule"].arn
    billingServices    = aws_lambda_function.this["billingServices"].arn
    zohoNotifier       = aws_lambda_function.this["zohoNotifier"].arn
    adminPanel         = aws_lambda_function.this["adminPanel"].arn
    arocordinsightsAuth  = aws_lambda_function.this["arocordinsightsAuth"].arn
  }
}

output "lambda_invoke_arns" {
  value = {
    signup            = aws_lambda_function.this["signup"].invoke_arn
    login             = aws_lambda_function.this["login"].invoke_arn
    dashboard         = aws_lambda_function.this["dashboard"].invoke_arn
    doctor            = aws_lambda_function.this["doctor"].invoke_arn
    patient           = aws_lambda_function.this["patient"].invoke_arn
    caretaker         = aws_lambda_function.this["caretaker"].invoke_arn
    clinicinfo        = aws_lambda_function.this["clinicinfo"].invoke_arn
    aisummarizer      = aws_lambda_function.this["aisummarizer"].invoke_arn
    insightsauth      = aws_lambda_function.this["insightsauth"].invoke_arn
    appinsights       = aws_lambda_function.this["appinsights"].invoke_arn
    refinenotes       = aws_lambda_function.this["refinenotes"].invoke_arn
    soapemailtemplate = aws_lambda_function.this["soapemailtemplate"].invoke_arn
    soapnotes         = aws_lambda_function.this["soapnotes"].invoke_arn
    transcription     = aws_lambda_function.this["transcription"].invoke_arn
    labTechnician     = aws_lambda_function.this["labTechnician"].invoke_arn
    auditlogger       = aws_lambda_function.this["auditlogger"].invoke_arn
    pharmacy          = aws_lambda_function.this["pharmacy"].invoke_arn
    inpatient          = aws_lambda_function.this["inpatient"].invoke_arn
    discharge          = aws_lambda_function.this["discharge"].invoke_arn
    wardsbeds          = aws_lambda_function.this["wardsbeds"].invoke_arn
    invoiceRecords     = aws_lambda_function.this["invoiceRecords"].invoke_arn
    paymentBilling     = aws_lambda_function.this["paymentBilling"].invoke_arn
    billingModule      = aws_lambda_function.this["billingModule"].invoke_arn
    billingServices    = aws_lambda_function.this["billingServices"].invoke_arn
    zohoNotifier       = aws_lambda_function.this["zohoNotifier"].invoke_arn
    adminPanel         = aws_lambda_function.this["adminPanel"].invoke_arn
    arocordinsightsAuth = aws_lambda_function.this["arocordinsightsAuth"].invoke_arn
  }
}

output "lambda_function_names" {
  value = {
    signup            = aws_lambda_function.this["signup"].function_name
    login             = aws_lambda_function.this["login"].function_name
    dashboard         = aws_lambda_function.this["dashboard"].function_name
    doctor            = aws_lambda_function.this["doctor"].function_name
    patient           = aws_lambda_function.this["patient"].function_name
    caretaker         = aws_lambda_function.this["caretaker"].function_name
    clinicinfo        = aws_lambda_function.this["clinicinfo"].function_name
    aisummarizer      = aws_lambda_function.this["aisummarizer"].function_name
    insightsauth      = aws_lambda_function.this["insightsauth"].function_name
    appinsights       = aws_lambda_function.this["appinsights"].function_name
    refinenotes       = aws_lambda_function.this["refinenotes"].function_name
    soapemailtemplate = aws_lambda_function.this["soapemailtemplate"].function_name
    soapnotes         = aws_lambda_function.this["soapnotes"].function_name
    transcription     = aws_lambda_function.this["transcription"].function_name
    labTechnician     = aws_lambda_function.this["labTechnician"].function_name
    auditlogger       = aws_lambda_function.this["auditlogger"].function_name
    pharmacy          = aws_lambda_function.this["pharmacy"].function_name
    inpatient          = aws_lambda_function.this["inpatient"].function_name
    discharge          = aws_lambda_function.this["discharge"].function_name
    wardsbeds          = aws_lambda_function.this["wardsbeds"].function_name
    invoiceRecords     = aws_lambda_function.this["invoiceRecords"].function_name
    paymentBilling     = aws_lambda_function.this["paymentBilling"].function_name
    billingModule      = aws_lambda_function.this["billingModule"].function_name
    billingServices    = aws_lambda_function.this["billingServices"].function_name
    zohoNotifier       = aws_lambda_function.this["zohoNotifier"].function_name
    adminPanel         = aws_lambda_function.this["adminPanel"].function_name
    arocordinsightsAuth = aws_lambda_function.this["arocordinsightsAuth"].function_name
    
  }
}

output "lambda_roles" {
  value = {
    signup            = aws_iam_role.lambda_role["signup"].arn
    login             = aws_iam_role.lambda_role["login"].arn
    dashboard         = aws_iam_role.lambda_role["dashboard"].arn
    doctor            = aws_iam_role.lambda_role["doctor"].arn
    patient           = aws_iam_role.lambda_role["patient"].arn
    caretaker         = aws_iam_role.lambda_role["caretaker"].arn
    clinicinfo        = aws_iam_role.lambda_role["clinicinfo"].arn
    aisummarizer      = aws_iam_role.lambda_role["aisummarizer"].arn
    insightsauth      = aws_iam_role.lambda_role["insightsauth"].arn
    appinsights       = aws_iam_role.lambda_role["appinsights"].arn
    refinenotes       = aws_iam_role.lambda_role["refinenotes"].arn
    soapemailtemplate = aws_iam_role.lambda_role["soapemailtemplate"].arn
    soapnotes         = aws_iam_role.lambda_role["soapnotes"].arn
    transcription     = aws_iam_role.lambda_role["transcription"].arn
    labTechnician     = aws_iam_role.lambda_role["labTechnician"].arn
    auditlogger       = aws_iam_role.lambda_role["auditlogger"].arn
    pharmacy          = aws_iam_role.lambda_role["pharmacy"].arn
    inpatient         = aws_iam_role.lambda_role["inpatient"].arn
    discharge         = aws_iam_role.lambda_role["discharge"].arn
    wardsbeds         = aws_iam_role.lambda_role["wardsbeds"].arn
    invoiceRecords    = aws_iam_role.lambda_role["invoiceRecords"].arn
    paymentBilling    = aws_iam_role.lambda_role["paymentBilling"].arn
    billingModule    = aws_iam_role.lambda_role["billingModule"].arn
    billingServices  = aws_iam_role.lambda_role["billingServices"].arn
    zohoNotifier     = aws_iam_role.lambda_role["zohoNotifier"].arn
    adminPanel       = aws_iam_role.lambda_role["adminPanel"].arn
    arocordinsightsAuth = aws_iam_role.lambda_role["arocordinsightsAuth"].arn
  }
}

# Lambda Function Outputs
output "signup_lambda_arn" {
  description = "ARN of Signup Lambda"
  value       = aws_lambda_function.this["signup"].arn
}
     
output "login_lambda_arn" {
  description = "ARN of Login Lambda"
  value       = aws_lambda_function.this["login"].arn
}

output "dashboard_lambda_arn" {
  description = "ARN of Dashboard Lambda"
  value       = aws_lambda_function.this["dashboard"].arn
}

output "aisummarizer_lambda_arn" {
  description = "ARN of AI Summarizer Lambda"
  value       = aws_lambda_function.this["aisummarizer"].arn
}




# Artifact Location (for debugging / reuse)
output "artifact_bucket" {
  description = "S3 bucket storing lambda artifacts"
  value       = var.artifact_bucket
}

output "artifact_base_path" {
  description = "Base path where ZIPs are stored"
  value       = "arocordinsights-standalone/arocord-summarizer-api/feature/api-setup/16"
}


# Worker Lambda Outputs

output "soap_email_template_worker_arn" {
  description = "ARN of the SOAP Email Template Worker Lambda"
  value       = aws_lambda_function.soap_email_template_worker.arn
}

output "soap_refine_worker_arn" {
  description = "ARN of the SOAP Refine Worker Lambda"
  value       = aws_lambda_function.soap_refine_worker.arn
}

output "transcription_worker_arn" {
  description = "ARN of the Transcription Worker Lambda"
  value       = aws_lambda_function.transcription_worker.arn
}

output "soap_worker_arn" {
  description = "ARN of the SOAP Worker Lambda"
  value       = aws_lambda_function.soap_worker.arn
}


#  invoke ARNs too

output "soap_email_template_worker_invoke_arn" {
  description = "Invoke ARN of the SOAP Email Template Worker Lambda"
  value       = aws_lambda_function.soap_email_template_worker.invoke_arn
}

output "soap_refine_worker_invoke_arn" {
  description = "Invoke ARN of the SOAP Refine Worker Lambda"
  value       = aws_lambda_function.soap_refine_worker.invoke_arn
}

output "transcription_worker_invoke_arn" {
  description = "Invoke ARN of the Transcription Worker Lambda"
  value       = aws_lambda_function.transcription_worker.invoke_arn
}

output "soap_worker_invoke_arn" {
  description = "Invoke ARN of the SOAP Worker Lambda"
  value       = aws_lambda_function.soap_worker.invoke_arn
}
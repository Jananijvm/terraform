output "transcript_jobs_table_name" {
  value = aws_dynamodb_table.transcript_jobs.name
}

output "transcript_jobs_table_arn" {
  value = aws_dynamodb_table.transcript_jobs.arn
}

output "audit_logs_table_name" {
  value = aws_dynamodb_table.audit_logs.name
}

output "audit_logs_table_arn" {
  value = aws_dynamodb_table.audit_logs.arn
}
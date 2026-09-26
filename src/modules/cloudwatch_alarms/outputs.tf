output "alarm_arns" {
  value = { for k, v in aws_cloudwatch_metric_alarm.lambda_alarms : k => v.arn }
}
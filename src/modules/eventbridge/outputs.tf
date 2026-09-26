output "event_rule_arn" {
  description = "Audit rule ARN"
  value       = aws_cloudwatch_event_rule.audit_rule.arn
}

output "event_bus_name" {
  description = "EventBridge bus name"
  value       = var.bus_name
}
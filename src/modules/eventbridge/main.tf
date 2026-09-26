resource "aws_cloudwatch_event_bus" "audit_bus" {
  name = var.bus_name
}

resource "aws_cloudwatch_event_rule" "audit_rule" {
  name           = var.rule_name
  event_bus_name = aws_cloudwatch_event_bus.audit_bus.name

  event_pattern = jsonencode({
    source        = ["audit.service"]
    "detail-type" = ["AuditLog"]
  })
}

resource "aws_cloudwatch_event_target" "audit_lambda_target" {
  rule           = aws_cloudwatch_event_rule.audit_rule.name
  event_bus_name = aws_cloudwatch_event_bus.audit_bus.name
  target_id      = "audit-lambda"
  arn            = var.lambda_arn
}

# THIS is the only permission that matters
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridgeAuditRule"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"

  #  IMPORTANT: permission is tied to RULE, not bus
  source_arn    = aws_cloudwatch_event_rule.audit_rule.arn
}
locals {
  alarm_metrics = {
    errors = {
      metric_name         = "Errors"
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 1
      threshold           = 1
      comparison_operator = "GreaterThanOrEqualToThreshold"
    }
    throttles = {
      metric_name         = "Throttles"
      statistic           = "Sum"
      period              = 60
      evaluation_periods  = 1
      threshold           = 1
      comparison_operator = "GreaterThanOrEqualToThreshold"
    }
    duration = {
      metric_name         = "Duration"
      statistic           = "Average"
      period              = 300
      evaluation_periods  = 2
      threshold           = 5000
      comparison_operator = "GreaterThanThreshold"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_alarms" {
  for_each = {
    for pair in flatten([
      for fn_name in var.function_names : [
        for alarm_key, alarm in local.alarm_metrics : {
          key                 = "${fn_name}-${alarm_key}"
          function_name       = fn_name
          alarm_key           = alarm_key
          metric_name         = alarm.metric_name
          statistic           = alarm.statistic
          period              = alarm.period
          evaluation_periods  = alarm.evaluation_periods
          threshold           = alarm.threshold
          comparison_operator = alarm.comparison_operator
        }
      ]
    ]) : pair.key => pair
  }

  alarm_name          = "${each.value.function_name}-${var.environment}-${each.value.alarm_key}"
  alarm_description   = "[${var.environment}] ${each.value.function_name} — ${each.value.alarm_key}"
  metric_name         = each.value.metric_name
  namespace           = "AWS/Lambda"
  statistic           = each.value.statistic
  period              = each.value.period
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison_operator
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value.function_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}
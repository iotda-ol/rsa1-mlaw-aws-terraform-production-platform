# CloudWatch Module - Comprehensive monitoring and observability

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }],
            ["AWS/EC2", "NetworkIn", { stat = "Sum" }],
            ["AWS/EC2", "NetworkOut", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average", dimensions = { ClusterName = var.ecs_cluster_name } }],
            ["AWS/ECS", "MemoryUtilization", { stat = "Average", dimensions = { ClusterName = var.ecs_cluster_name } }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Cluster Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum" }],
            ["AWS/Lambda", "Errors", { stat = "Sum" }],
            ["AWS/Lambda", "Duration", { stat = "Average" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Lambda Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", { dimensions = { BucketName = var.artifacts_bucket_name, StorageType = "StandardStorage" } }],
            ["AWS/S3", "NumberOfObjects", { dimensions = { BucketName = var.artifacts_bucket_name, StorageType = "AllStorageTypes" } }]
          ]
          period = 86400
          stat   = "Average"
          region = var.aws_region
          title  = "S3 Metrics"
        }
      },
      {
        type = "log"
        properties = {
          query  = "SOURCE '/aws/ecs/${var.project_name}' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region = var.aws_region
          title  = "Recent ECS Logs"
        }
      }
    ]
  })
}

# CloudWatch Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "${var.project_name}-error-count"
  log_group_name = "/aws/ecs/${var.project_name}"
  pattern        = "[time, request_id, event_type = ERROR*, ...]"

  metric_transformation {
    name          = "ErrorCount"
    namespace     = var.project_name
    value         = "1"
    default_value = 0
  }
}

# Composite Alarm for critical infrastructure issues
resource "aws_cloudwatch_composite_alarm" "critical_infrastructure" {
  alarm_name        = "${var.project_name}-critical-infrastructure"
  alarm_description = "Composite alarm for critical infrastructure issues"
  actions_enabled   = true
  alarm_actions     = var.create_sns_topic ? [aws_sns_topic.cloudwatch_alarms[0].arn] : var.alarm_actions

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.high_error_rate.alarm_name}) OR ALARM(${aws_cloudwatch_metric_alarm.low_healthy_hosts.alarm_name})"

  depends_on = [
    aws_cloudwatch_metric_alarm.high_error_rate,
    aws_cloudwatch_metric_alarm.low_healthy_hosts
  ]
}

# Alarm for high error rate
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ErrorCount"
  namespace           = var.project_name
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when error rate is high"
  treat_missing_data  = "notBreaching"

  tags = var.common_tags
}

# Alarm for low healthy hosts
resource "aws_cloudwatch_metric_alarm" "low_healthy_hosts" {
  alarm_name          = "${var.project_name}-low-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when healthy host count is low"
  treat_missing_data  = "breaching"

  tags = var.common_tags
}

# CloudWatch Insights Query definitions
resource "aws_cloudwatch_query_definition" "error_analysis" {
  name = "${var.project_name}/error-analysis"

  log_group_names = [
    "/aws/ecs/${var.project_name}",
    "/aws/lambda/${var.project_name}-automation"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /ERROR/
    | stats count() by @logStream
    | sort count() desc
  QUERY
}

resource "aws_cloudwatch_query_definition" "performance_analysis" {
  name = "${var.project_name}/performance-analysis"

  log_group_names = [
    "/aws/ecs/${var.project_name}"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @type = "REPORT"
    | stats avg(@duration), max(@duration), min(@duration) by bin(5m)
  QUERY
}

# SNS Topic for CloudWatch Alarms (optional)
resource "aws_sns_topic" "cloudwatch_alarms" {
  count = var.create_sns_topic ? 1 : 0
  name  = "${var.project_name}-cloudwatch-alarms"

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "cloudwatch_alarms_email" {
  count     = var.create_sns_topic && var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.cloudwatch_alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

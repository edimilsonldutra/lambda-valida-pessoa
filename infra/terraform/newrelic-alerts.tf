# New Relic Alert Policies Configuration
# This file contains the alert conditions to be configured in New Relic

resource "newrelic_alert_policy" "valida_pessoa_policy" {
  name                = "ValidaPessoa Lambda - ${var.environment}"
  incident_preference = "PER_POLICY"
}

# ============================================================================
# Performance Alerts
# ============================================================================

# High API Latency Alert
resource "newrelic_nrql_alert_condition" "high_latency" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "High API Latency"
  description                  = "Alert when average response time exceeds 3 seconds"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT average(duration) FROM Transaction WHERE appName = '${var.new_relic_app_name}' FACET name"
  }

  critical {
    operator              = "above"
    threshold             = 3.0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 2.0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# Slow Database Queries
resource "newrelic_nrql_alert_condition" "slow_database_queries" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "Slow Database Queries"
  description                  = "Alert when database queries exceed 1 second"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/Database/Query/Duration' AND appName = '${var.new_relic_app_name}'"
  }

  critical {
    operator              = "above"
    threshold             = 1000
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 500
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# ============================================================================
# Error Rate Alerts
# ============================================================================

# High Error Rate
resource "newrelic_nrql_alert_condition" "high_error_rate" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "High Error Rate"
  description                  = "Alert when error rate exceeds 5%"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT percentage(count(*), WHERE error IS true) FROM Transaction WHERE appName = '${var.new_relic_app_name}'"
  }

  critical {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# Processing Failures
resource "newrelic_nrql_alert_condition" "processing_failures" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "Processing Failures"
  description                  = "Alert when auth request failures spike"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM Log WHERE event = 'auth_request_failed' AND service = 'ValidaPessoa'"
  }

  critical {
    operator              = "above"
    threshold             = 10
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# ============================================================================
# Resource Utilization Alerts
# ============================================================================

# High Memory Usage
resource "newrelic_nrql_alert_condition" "high_memory_usage" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "High Memory Usage"
  description                  = "Alert when JVM memory usage exceeds 90%"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT max(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/JVM/Memory/UsagePercent' AND appName = '${var.new_relic_app_name}'"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# CPU Load Average
resource "newrelic_nrql_alert_condition" "high_cpu_load" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "High CPU Load"
  description                  = "Alert when CPU load is consistently high"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT average(newrelic.timeslice.value) FROM Metric WHERE metricTimesliceName = 'Custom/JVM/CPU/LoadAverage' AND appName = '${var.new_relic_app_name}'"
  }

  critical {
    operator              = "above"
    threshold             = 0.8
    threshold_duration    = 600
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 0.6
    threshold_duration    = 600
    threshold_occurrences = "all"
  }
}

# ============================================================================
# Availability Alerts
# ============================================================================

# Low Throughput (Possible Downtime)
resource "newrelic_nrql_alert_condition" "low_throughput" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "Low Throughput - Possible Downtime"
  description                  = "Alert when request rate drops significantly"
  enabled                      = var.environment == "prod"
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = '${var.new_relic_app_name}'"
  }

  critical {
    operator              = "below"
    threshold             = 0.1
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# Lambda Timeouts
resource "newrelic_nrql_alert_condition" "lambda_timeouts" {
  policy_id                    = newrelic_alert_policy.valida_pessoa_policy.id
  type                         = "static"
  name                         = "Lambda Function Timeouts"
  description                  = "Alert when Lambda functions are timing out"
  enabled                      = true
  violation_time_limit_seconds = 3600

  nrql {
    query = "SELECT count(*) FROM TransactionError WHERE appName = '${var.new_relic_app_name}' AND error.class = 'com.amazonaws.services.lambda.runtime.LambdaTimeoutException'"
  }

  critical {
    operator              = "above"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
}

# ============================================================================
# Notification Channels
# ============================================================================

# Email Notification Channel
resource "newrelic_alert_channel" "email" {
  name = "Email - ValidaPessoa ${var.environment}"
  type = "email"

  config {
    recipients              = var.alert_email_recipients
    include_json_attachment = "true"
  }
}

# Slack Notification Channel (optional)
resource "newrelic_alert_channel" "slack" {
  count = var.enable_slack_notifications ? 1 : 0

  name = "Slack - ValidaPessoa ${var.environment}"
  type = "slack"

  config {
    url     = var.slack_webhook_url
    channel = var.slack_channel
  }
}

# PagerDuty Channel (for production critical alerts)
resource "newrelic_alert_channel" "pagerduty" {
  count = var.environment == "prod" && var.enable_pagerduty ? 1 : 0

  name = "PagerDuty - ValidaPessoa Production"
  type = "pagerduty"

  config {
    service_key = var.pagerduty_service_key
  }
}

# ============================================================================
# Link Channels to Policy
# ============================================================================

resource "newrelic_alert_policy_channel" "email_channel" {
  policy_id  = newrelic_alert_policy.valida_pessoa_policy.id
  channel_ids = [
    newrelic_alert_channel.email.id
  ]
}

resource "newrelic_alert_policy_channel" "slack_channel" {
  count = var.enable_slack_notifications ? 1 : 0

  policy_id  = newrelic_alert_policy.valida_pessoa_policy.id
  channel_ids = [
    newrelic_alert_channel.slack[0].id
  ]
}

resource "newrelic_alert_policy_channel" "pagerduty_channel" {
  count = var.environment == "prod" && var.enable_pagerduty ? 1 : 0

  policy_id  = newrelic_alert_policy.valida_pessoa_policy.id
  channel_ids = [
    newrelic_alert_channel.pagerduty[0].id
  ]
}

# ============================================================================
# Variables for Alerts
# ============================================================================

variable "new_relic_app_name" {
  description = "New Relic application name"
  type        = string
  default     = "ValidaPessoa Lambda"
}

variable "alert_email_recipients" {
  description = "Email recipients for alerts"
  type        = string
  default     = "devops@example.com"
}

variable "enable_slack_notifications" {
  description = "Enable Slack notifications"
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = ""
}

variable "slack_channel" {
  description = "Slack channel for notifications"
  type        = string
  default     = "#alerts"
}

variable "enable_pagerduty" {
  description = "Enable PagerDuty integration"
  type        = bool
  default     = false
}

variable "pagerduty_service_key" {
  description = "PagerDuty service integration key"
  type        = string
  sensitive   = true
  default     = ""
}


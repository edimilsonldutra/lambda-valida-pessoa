# New Relic Alert Policies Configuration
# This file contains the alert conditions to be configured in New Relic
# Only created when New Relic monitoring is enabled and credentials are provided

resource "newrelic_alert_policy" "valida_pessoa_policy" {
  count = local.enable_newrelic ? 1 : 0

  name                = "ValidaPessoa Lambda - ${var.environment}"
  incident_preference = "PER_POLICY"
}

# ============================================================================
# Performance Alerts
# ============================================================================

# High API Latency Alert
resource "newrelic_nrql_alert_condition" "high_latency" {
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
  count = local.enable_newrelic ? 1 : 0

  policy_id                    = newrelic_alert_policy.valida_pessoa_policy[0].id
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
# Notification Destinations (New Workflow-based Notifications)
# ============================================================================

# Email Notification Destination
resource "newrelic_notification_destination" "email" {
  count = local.enable_newrelic && var.alert_email_recipients != "" ? 1 : 0

  name = "Email - ValidaPessoa ${var.environment}"
  type = "EMAIL"

  property {
    key   = "email"
    value = var.alert_email_recipients
  }
}

# Slack Notification Destination
resource "newrelic_notification_destination" "slack" {
  count = local.enable_newrelic && var.enable_slack_notifications ? 1 : 0

  name = "Slack - ValidaPessoa ${var.environment}"
  type = "SLACK"

  property {
    key   = "url"
    value = var.slack_webhook_url
  }
}

# PagerDuty Notification Destination
resource "newrelic_notification_destination" "pagerduty" {
  count = local.enable_newrelic && var.environment == "prod" && var.enable_pagerduty ? 1 : 0

  name = "PagerDuty - ValidaPessoa Production"
  type = "PAGERDUTY_SERVICE_INTEGRATION"

  property {
    key   = "summary"
    value = "ValidaPessoa Alert - {{ issueTitle }}"
  }

  auth_token {
    prefix = "Token token="
    token  = var.pagerduty_service_key
  }
}

# ============================================================================
# Notification Channels (Link Destinations to Workflows)
# ============================================================================

# Email Notification Channel
resource "newrelic_notification_channel" "email" {
  count = local.enable_newrelic && var.alert_email_recipients != "" ? 1 : 0

  name           = "Email Channel - ValidaPessoa ${var.environment}"
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.email[0].id
  product        = "IINT" # Incident Intelligence

  property {
    key   = "subject"
    value = "Alert: {{ issueTitle }}"
  }

  property {
    key   = "customDetailsEmail"
    value = "Issue ID: {{ issueId }}"
  }
}

# Slack Notification Channel
resource "newrelic_notification_channel" "slack" {
  count = local.enable_newrelic && var.enable_slack_notifications ? 1 : 0

  name           = "Slack Channel - ValidaPessoa ${var.environment}"
  type           = "SLACK"
  destination_id = newrelic_notification_destination.slack[0].id
  product        = "IINT"

  property {
    key   = "channelId"
    value = var.slack_channel
  }

  property {
    key   = "customDetailsSlack"
    value = "Issue: {{ issueTitle }}\nPriority: {{ priority }}\nEnvironment: ${var.environment}"
  }
}

# PagerDuty Notification Channel
resource "newrelic_notification_channel" "pagerduty" {
  count = local.enable_newrelic && var.environment == "prod" && var.enable_pagerduty ? 1 : 0

  name           = "PagerDuty Channel - ValidaPessoa Production"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.pagerduty[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "{{ annotations.title.[0] }}"
  }

  property {
    key   = "customDetails"
    value = jsonencode({
      id       = "{{ issueId }}"
      priority = "{{ priority }}"
    })
  }
}

# ============================================================================
# Workflows (Link Channels to Alert Policies)
# ============================================================================

# Email Workflow
resource "newrelic_workflow" "email_workflow" {
  count = local.enable_newrelic && var.alert_email_recipients != "" ? 1 : 0

  name                  = "Email Workflow - ValidaPessoa ${var.environment}"
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter by Policy"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.valida_pessoa_policy[0].id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.email[0].id
  }
}

# Slack Workflow
resource "newrelic_workflow" "slack_workflow" {
  count = local.enable_newrelic && var.enable_slack_notifications ? 1 : 0

  name                  = "Slack Workflow - ValidaPessoa ${var.environment}"
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter by Policy"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.valida_pessoa_policy[0].id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.slack[0].id
  }
}

# PagerDuty Workflow (Production only, critical alerts)
resource "newrelic_workflow" "pagerduty_workflow" {
  count = local.enable_newrelic && var.environment == "prod" && var.enable_pagerduty ? 1 : 0

  name                  = "PagerDuty Workflow - ValidaPessoa Production"
  enabled               = true
  muting_rules_handling = "DONT_NOTIFY_FULLY_MUTED_ISSUES"

  issues_filter {
    name = "Filter by Policy and Priority"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.valida_pessoa_policy[0].id]
    }

    predicate {
      attribute = "priority"
      operator  = "EQUAL"
      values    = ["CRITICAL"]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.pagerduty[0].id
  }
}



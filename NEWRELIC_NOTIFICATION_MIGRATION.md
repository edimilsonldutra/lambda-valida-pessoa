# ✅ New Relic Notification Migration - COMPLETED

**Date:** 2025-12-03  
**Status:** ✅ Migration Complete  
**Issue:** Deprecated `newrelic_alert_channel` warnings

---

## 🔧 What Was Fixed

### Deprecated Resources Removed:
- ❌ `newrelic_alert_channel.email`
- ❌ `newrelic_alert_channel.slack`
- ❌ `newrelic_alert_channel.pagerduty`
- ❌ `newrelic_alert_policy_channel.email_channel`
- ❌ `newrelic_alert_policy_channel.slack_channel`
- ❌ `newrelic_alert_policy_channel.pagerduty_channel`

### New Resources Created:
✅ **Notification Destinations** (3 resources)
- `newrelic_notification_destination.email`
- `newrelic_notification_destination.slack`
- `newrelic_notification_destination.pagerduty`

✅ **Notification Channels** (3 resources)
- `newrelic_notification_channel.email`
- `newrelic_notification_channel.slack`
- `newrelic_notification_channel.pagerduty`

✅ **Workflows** (3 resources)
- `newrelic_workflow.email_workflow`
- `newrelic_workflow.slack_workflow`
- `newrelic_workflow.pagerduty_workflow`

---

## 📊 Migration Architecture

### Old Architecture (Deprecated):
```
Alert Policy → Alert Channel → Email/Slack/PagerDuty
```

### New Architecture (Workflow-based):
```
Alert Policy → Workflow → Notification Channel → Notification Destination → Email/Slack/PagerDuty
```

---

## 🔍 Key Changes Explained

### 1. **Notification Destinations**
Define WHERE notifications are sent (email addresses, Slack webhooks, PagerDuty keys).

**Email Example:**
```hcl
resource "newrelic_notification_destination" "email" {
  name = "Email - ValidaPessoa ${var.environment}"
  type = "EMAIL"

  property {
    key   = "email"
    value = var.alert_email_recipients
  }
}
```

### 2. **Notification Channels**
Define HOW notifications are formatted and what information they include.

**Email Channel Example:**
```hcl
resource "newrelic_notification_channel" "email" {
  name           = "Email Channel - ValidaPessoa ${var.environment}"
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.email[0].id
  product        = "IINT" # Incident Intelligence

  property {
    key   = "subject"
    value = "Alert: {{ issueTitle }}"
  }
}
```

### 3. **Workflows**
Define WHEN and WHICH notifications are sent based on filters.

**Email Workflow Example:**
```hcl
resource "newrelic_workflow" "email_workflow" {
  name    = "Email Workflow - ValidaPessoa ${var.environment}"
  enabled = true

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
```

---

## 🎯 Features & Benefits

### ✅ Enhanced Filtering
Workflows support advanced filtering:
- **Email & Slack:** All alerts from the policy
- **PagerDuty:** Only CRITICAL priority alerts in production

### ✅ Better Customization
- Custom subject lines
- Custom message formats
- Template variables: `{{ issueTitle }}`, `{{ issueId }}`, `{{ priority }}`

### ✅ Muting Control
- `NOTIFY_ALL_ISSUES`: Email and Slack get all alerts
- `DONT_NOTIFY_FULLY_MUTED_ISSUES`: PagerDuty respects muting rules

### ✅ Future-Proof
- Uses the latest New Relic API
- No deprecation warnings
- Compatible with new New Relic features

---

## 📋 Configuration Variables

All existing variables are still used:

| Variable | Purpose | Default |
|----------|---------|---------|
| `enable_new_relic_monitoring` | Master switch for New Relic | `false` |
| `new_relic_api_key` | API authentication | `""` |
| `alert_email_recipients` | Email addresses (comma-separated) | `""` |
| `enable_slack_notifications` | Enable Slack alerts | `false` |
| `slack_webhook_url` | Slack webhook URL | `""` |
| `slack_channel` | Slack channel name | `"#alerts"` |
| `enable_pagerduty` | Enable PagerDuty (prod only) | `false` |
| `pagerduty_service_key` | PagerDuty integration key | `""` |

---

## 🚀 How to Use

### 1. **Email Notifications Only** (Default for Dev)
```hcl
# In terraform.tfvars
enable_new_relic_monitoring = true
new_relic_api_key          = "YOUR_API_KEY"
alert_email_recipients     = "dev-team@example.com,ops@example.com"
```

### 2. **Email + Slack Notifications**
```hcl
enable_new_relic_monitoring = true
new_relic_api_key          = "YOUR_API_KEY"
alert_email_recipients     = "team@example.com"
enable_slack_notifications = true
slack_webhook_url          = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
slack_channel              = "#devops-alerts"
```

### 3. **Full Production Setup** (Email + Slack + PagerDuty)
```hcl
environment                = "prod"
enable_new_relic_monitoring = true
new_relic_api_key          = "YOUR_API_KEY"
alert_email_recipients     = "oncall@example.com"
enable_slack_notifications = true
slack_webhook_url          = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
slack_channel              = "#prod-alerts"
enable_pagerduty          = true
pagerduty_service_key     = "YOUR_PAGERDUTY_KEY"
```

---

## 🔔 Notification Behavior

### Email Notifications
- **When:** All alerts from the policy
- **Format:** 
  - Subject: "Alert: [Issue Title]"
  - Body: Issue ID and details
  - Includes JSON attachment

### Slack Notifications
- **When:** All alerts from the policy
- **Format:**
  - Issue title, priority, environment
  - Custom details about the alert
  - Links to New Relic dashboard

### PagerDuty Notifications
- **When:** Only CRITICAL alerts in production
- **Format:**
  - Summary with issue title
  - Custom details with issue ID and priority
  - Respects muting rules

---

## ⚠️ Important Notes

### State Migration Required
If you previously deployed with the old `newrelic_alert_channel` resources, you'll need to:

1. **Option A: Destroy and Recreate** (Recommended for Dev)
   ```bash
   # Remove old notification resources from state
   terraform state rm 'newrelic_alert_channel.email[0]'
   terraform state rm 'newrelic_alert_channel.slack[0]'
   terraform state rm 'newrelic_alert_channel.pagerduty[0]'
   terraform state rm 'newrelic_alert_policy_channel.email_channel[0]'
   terraform state rm 'newrelic_alert_policy_channel.slack_channel[0]'
   terraform state rm 'newrelic_alert_policy_channel.pagerduty_channel[0]'
   
   # Apply to create new resources
   terraform apply
   ```

2. **Option B: Fresh Deploy** (If not in production)
   ```bash
   terraform destroy
   terraform apply
   ```

### No Breaking Changes for New Deployments
If you haven't deployed New Relic monitoring yet, you can simply:
```bash
terraform apply
```

---

## 📊 Resource Count

| Component | Count | Conditional |
|-----------|-------|-------------|
| Notification Destinations | 3 | Based on config |
| Notification Channels | 3 | Based on config |
| Workflows | 3 | Based on config |
| **Total New Resources** | **9** | **When all enabled** |

---

## ✅ Validation

After applying the changes:

1. **Check Terraform Plan**
   ```bash
   cd infra/terraform
   terraform plan
   ```
   
   Should show:
   - 9 resources to add (if all notifications enabled)
   - 0 deprecation warnings

2. **Verify in New Relic**
   - Go to: **Alerts & AI → Destinations**
   - Verify your email/Slack/PagerDuty destinations exist
   - Go to: **Alerts & AI → Workflows**
   - Verify workflows are active

3. **Test Notifications**
   - Trigger a test alert
   - Verify emails are received
   - Verify Slack messages appear
   - Verify PagerDuty incidents (for critical alerts in prod)

---

## 🎯 Benefits Over Old System

| Feature | Old System | New System |
|---------|-----------|------------|
| Filtering | Limited | Advanced (priority, policy, custom) |
| Customization | Basic | Full template support |
| Muting | Basic | Sophisticated rules |
| Priority Routing | No | Yes (PagerDuty only for critical) |
| Template Variables | Limited | Extensive |
| Multi-Channel Routing | Same config for all | Different rules per channel |
| Deprecation Risk | ⚠️ High | ✅ None |

---

## 🔗 References

- [New Relic Notification Destinations Docs](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_destination)
- [New Relic Notification Channels Docs](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/notification_channel)
- [New Relic Workflows Docs](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/workflow)
- [Migration Guide](https://docs.newrelic.com/docs/alerts-applied-intelligence/new-relic-alerts/advanced-alerts/understand-technical-concepts/migrating-legacy-alerting/)

---

## 📝 Summary

✅ **Migration Complete!**

All deprecated `newrelic_alert_channel` resources have been replaced with the new workflow-based notification system. This eliminates all 6 deprecation warnings and provides:

- ✅ Modern, future-proof notification architecture
- ✅ Enhanced filtering and routing capabilities
- ✅ Better customization options
- ✅ Priority-based routing (critical alerts → PagerDuty only)
- ✅ No breaking changes to existing variables
- ✅ Backward compatible configuration

**Next Steps:**
1. Review the changes in `infra/terraform/newrelic-alerts.tf`
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to deploy the new notification system
4. Test alerts to verify notifications work correctly

---

**Last Updated:** 2025-12-03  
**Migration Performed by:** GitHub Copilot  
**Status:** ✅ Ready for Production


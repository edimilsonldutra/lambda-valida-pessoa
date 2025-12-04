# 🚀 Quick Reference - New Relic Notifications

## ✅ What Changed?

**Deprecated (Removed):**
- `newrelic_alert_channel` → **Removed**
- `newrelic_alert_policy_channel` → **Removed**

**New (Created):**
- `newrelic_notification_destination` → **Where to send**
- `newrelic_notification_channel` → **How to format**
- `newrelic_workflow` → **When to send**

---

## 🎯 Quick Deploy Commands

```bash
# Navigate to terraform directory
cd "C:\Users\Meu Computador\OneDrive\Área de Trabalho\FIAP\projeto\fase_tres\lambda-valida-pessoa\infra\terraform"

# Validate configuration
terraform validate

# See what will change
terraform plan

# Apply changes
terraform apply
```

---

## 📋 Configuration Examples

### Email Only (Dev)
```hcl
# terraform.tfvars
enable_new_relic_monitoring = true
new_relic_api_key          = "NRAK-YOUR-KEY"
alert_email_recipients     = "team@example.com"
```

### Email + Slack
```hcl
enable_new_relic_monitoring = true
new_relic_api_key          = "NRAK-YOUR-KEY"
alert_email_recipients     = "team@example.com"
enable_slack_notifications = true
slack_webhook_url          = "https://hooks.slack.com/services/XXX/YYY/ZZZ"
slack_channel              = "#alerts"
```

### Full (Prod)
```hcl
environment                = "prod"
enable_new_relic_monitoring = true
new_relic_api_key          = "NRAK-YOUR-KEY"
alert_email_recipients     = "oncall@example.com"
enable_slack_notifications = true
slack_webhook_url          = "https://hooks.slack.com/services/XXX/YYY/ZZZ"
enable_pagerduty          = true
pagerduty_service_key     = "YOUR-INTEGRATION-KEY"
```

---

## 🔍 Verify Deployment

1. **Terraform**
   ```bash
   terraform validate  # Should be: "Success! The configuration is valid."
   ```

2. **New Relic Console**
   - Go to: **Alerts & AI → Destinations**
   - Verify: Email, Slack, PagerDuty destinations exist
   - Go to: **Alerts & AI → Workflows**
   - Verify: 3 workflows are active

3. **Test Notification**
   - Wait for next alert OR
   - Trigger test by causing an error in Lambda

---

## 📚 Full Documentation

- **Complete Migration Guide:** `NEWRELIC_NOTIFICATION_MIGRATION.md`
- **Detailed Fix Report:** `CORRECAO_WARNINGS_NEWRELIC.md`
- **Project Status:** `STATUS_CONFIGURACAO_FINAL.md`

---

## ⚡ Key Benefits

✅ **0 Deprecation Warnings** (was 6)  
✅ **Future-proof** - Latest New Relic API  
✅ **Advanced Filtering** - Route by priority  
✅ **Better Customization** - Templates & variables  
✅ **Muting Control** - Sophisticated rules  
✅ **No Config Changes** - Same variables work  

---

**Status:** ✅ Ready to Deploy  
**Last Updated:** 2025-12-03


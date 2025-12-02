# GitHub Actions Secrets Configuration

## Required Secrets

### AWS Credentials
```
Name: AWS_ACCESS_KEY_ID
Value: AKIAIOSFODNN7EXAMPLE
```

```
Name: AWS_SECRET_ACCESS_KEY
Value: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Application Secrets
```
Name: JWT_SECRET
Value: your-super-secret-jwt-key-minimum-32-characters-long
```

```
Name: DB_PASSWORD
Value: YourStrongDatabasePassword123!
```

```
Name: ALERT_EMAIL
Value: devops@yourcompany.com
```

### Optional Secrets
```
Name: NEW_RELIC_LICENSE_KEY
Value: eu01xx66c7e7f4c5b28f0b0c3e4e5f6g7h8i9j0k
```

```
Name: SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX
```

---

## How to Add Secrets in GitHub

1. Go to your repository
2. Click **Settings**
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Enter name and value
6. Click **Add secret**

---

## How to Generate Strong Secrets

### JWT_SECRET (32+ characters)
```bash
# Linux/Mac/Git Bash
openssl rand -base64 48

# PowerShell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 48 | ForEach-Object {[char]$_})

# Python
python -c "import secrets; print(secrets.token_urlsafe(48))"
```

### DB_PASSWORD
Use a password manager or:
```bash
openssl rand -base64 32
```

---

## Verify Secrets

Secrets are masked in logs and cannot be viewed after creation.

To verify they're working, check the workflow run logs for:
- ✅ No "secret not found" errors
- ✅ Successful AWS authentication
- ✅ Successful Terraform apply


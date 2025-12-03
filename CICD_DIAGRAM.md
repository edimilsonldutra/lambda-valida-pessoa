# 🎨 Diagrama Visual do CI/CD Pipeline

## 📊 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                        GITHUB REPOSITORY                             │
│                                                                       │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐                  │
│  │ feature/ │      │ bugfix/  │      │ hotfix/  │                  │
│  │ branches │      │ branches │      │ branches │                  │
│  └────┬─────┘      └────┬─────┘      └────┬─────┘                  │
│       │                 │                  │                         │
│       └─────────────────┴──────────────────┘                         │
│                         │                                            │
│                    Pull Request                                      │
│                         ↓                                            │
│  ┌─────────────────────────────────────────────────────┐            │
│  │            🔍 PR VALIDATION WORKFLOW                │            │
│  │  • Check PR title (Conventional Commits)            │            │
│  │  • Check PR description & branch name               │            │
│  │  • Check PR size (warn if > 500 lines)              │            │
│  │  • Build & Test                                     │            │
│  │  • Code Quality (Checkstyle, PMD, SpotBugs)         │            │
│  │  • Security Scan (OWASP, Snyk)                      │            │
│  │  • Coverage Report (JaCoCo)                         │            │
│  │  • Auto-label                                       │            │
│  │  • Status Comment                                   │            │
│  └─────────────────────────────────────────────────────┘            │
│                         │                                            │
│                    ✅ All Checks Pass                                │
│                    👥 1 Approval                                     │
│                         ↓                                            │
│  ┌────────────────────────────────────────────┐                     │
│  │         develop (DEVELOPMENT)              │  🔒 Protected       │
│  │  • No direct commits                       │  • Require PR       │
│  │  • Require 1 approval                      │  • Status checks    │
│  └────────────────┬───────────────────────────┘                     │
│                   │                                                  │
│              Push to develop                                         │
│                   ↓                                                  │
│  ┌─────────────────────────────────────────────────────┐            │
│  │       🚀 CD DEVELOPMENT WORKFLOW (AUTO)             │            │
│  │  1. Build Lambda JAR                                │            │
│  │  2. Upload to S3 (dev bucket)                       │            │
│  │  3. Update Lambda function (dev)                    │            │
│  │  4. Deploy Infrastructure (Terraform dev)           │            │
│  │  5. Run Smoke Tests                                 │            │
│  │  6. Check CloudWatch Logs                           │            │
│  │  7. Create deployment tag (dev-XXXXXXXX)            │            │
│  │  8. Notify Slack                                    │            │
│  └─────────────────────────────────────────────────────┘            │
│                   │                                                  │
│                   ↓                                                  │
│         🌍 AWS Development Environment                               │
│         • lambda-valida-pessoa-dev                                   │
│         • api-gateway-dev                                            │
│         • dynamodb-dev                                               │
│                                                                       │
│  ─────────────────────────────────────────────────────────────      │
│                                                                       │
│              Weekly Sync PR or Manual PR                             │
│          develop ──────────────────→ main                            │
│                         │                                            │
│                    Pull Request                                      │
│                         ↓                                            │
│  ┌─────────────────────────────────────────────────────┐            │
│  │            🔍 CI PIPELINE (FULL SUITE)              │            │
│  │  • Code Quality & Security (SonarCloud)             │            │
│  │  • Build & Unit Tests (Maven)                       │            │
│  │  • Integration Tests (LocalStack)                   │            │
│  │  • Docker Build Validation                          │            │
│  │  • Trivy Security Scan                              │            │
│  │  • Terraform Validation (fmt, validate, tflint)     │            │
│  │  • Coverage Check (70% minimum)                     │            │
│  └─────────────────────────────────────────────────────┘            │
│                         │                                            │
│                    ✅ All CI Checks Pass                             │
│                    👥 2-3 Approvals                                  │
│                    📋 Conversations Resolved                         │
│                         ↓                                            │
│  ┌────────────────────────────────────────────┐                     │
│  │           main (PRODUCTION)                │  🔒🔒 Protected     │
│  │  • No direct commits                       │  • Require PR       │
│  │  • Require 2-3 approvals                   │  • Code owners      │
│  │  • Require code owner review               │  • 4 status checks  │
│  └────────────────┬───────────────────────────┘  • Admins enforced  │
│                   │                                                  │
│              Push to main                                            │
│                   ↓                                                  │
│  ┌─────────────────────────────────────────────────────┐            │
│  │    🚀 CD PRODUCTION WORKFLOW (MANUAL APPROVAL)      │            │
│  │                                                      │            │
│  │  PHASE 1: Pre-Deployment                            │            │
│  │  • Run all tests again                              │            │
│  │  • Security scan                                    │            │
│  │  • Check coverage                                   │            │
│  │                                                      │            │
│  │  PHASE 2: Manual Approval Gate                      │            │
│  │  • 👥 Require 2-3 reviewers approval                │            │
│  │  • ⏱️  Wait timer: 5 minutes                         │            │
│  │                                                      │            │
│  │  PHASE 3: Blue/Green Deployment                     │            │
│  │  • 💾 Backup current version (create alias)         │            │
│  │  • 📦 Build & upload to S3 (prod bucket)            │            │
│  │  • 🚀 Deploy new version                            │            │
│  │  • 🔵 Canary: Route 10% traffic                     │            │
│  │  • ⏱️  Monitor for 5 minutes                         │            │
│  │  • 📊 Check CloudWatch metrics (errors)             │            │
│  │  • ✅ If OK: Route 100% traffic                     │            │
│  │  • ❌ If Error: Automatic rollback                  │            │
│  │                                                      │            │
│  │  PHASE 4: Infrastructure                            │            │
│  │  • Deploy Terraform (production)                    │            │
│  │                                                      │            │
│  │  PHASE 5: Testing & Validation                      │            │
│  │  • Health check                                     │            │
│  │  • Smoke tests                                      │            │
│  │  • Production verification                          │            │
│  │                                                      │            │
│  │  PHASE 6: Finalization                              │            │
│  │  • Create release tag (vYYYY.MM.DD-XXXXXXXX)        │            │
│  │  • Notify Slack                                     │            │
│  │  • Send email notification                          │            │
│  └─────────────────────────────────────────────────────┘            │
│                   │                                                  │
│                   ↓                                                  │
│         🌍 AWS Production Environment                                │
│         • lambda-valida-pessoa-prod                                  │
│         • api-gateway-prod                                           │
│         • dynamodb-prod                                              │
│         • New Relic Monitoring                                       │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Dados Detalhado

### Developer Workflow

```
Developer                GitHub Actions              AWS
    │                           │                     │
    │ 1. Create feature branch  │                     │
    │──────────────────────────>│                     │
    │                           │                     │
    │ 2. Push code              │                     │
    │──────────────────────────>│                     │
    │                           │                     │
    │ 3. Create PR              │                     │
    │──────────────────────────>│                     │
    │                           │                     │
    │                    4. Run PR Validation         │
    │                           │                     │
    │                    ├─ Build & Test              │
    │                    ├─ Code Quality              │
    │                    ├─ Security Scan             │
    │                    └─ Coverage Report           │
    │                           │                     │
    │<──── 5. Comment Status ───┤                     │
    │                           │                     │
    │ 6. Request Review         │                     │
    │──────────────────────────>│                     │
    │                           │                     │
    │<──── 7. Approval ─────────┤                     │
    │                           │                     │
    │ 8. Merge PR               │                     │
    │──────────────────────────>│                     │
    │                           │                     │
    │                    9. Trigger CD Dev            │
    │                           │                     │
    │                           │  10. Build JAR      │
    │                           │─────────────────────>│
    │                           │                     │
    │                           │  11. Update Lambda  │
    │                           │─────────────────────>│
    │                           │                     │
    │                           │  12. Smoke Tests    │
    │                           │<────────────────────┤
    │                           │                     │
    │<──── 13. Slack Notify ────┤                     │
    │                           │                     │
```

---

## 🎯 Decision Points

```
┌─────────────────┐
│   New Change    │
└────────┬────────┘
         │
         ▼
    ┌─────────┐
    │ Feature │
    │ Bugfix? │
    │ Hotfix? │
    └────┬────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────┐   ┌─────────┐
│Feat/│   │ Hotfix  │
│Bug  │   │(urgent) │
└──┬──┘   └────┬────┘
   │           │
   │ PR to     │ PR to
   │ develop   │ main
   │           │ (fast-track)
   ▼           ▼
┌────────┐  ┌──────┐
│develop │  │ main │
└───┬────┘  └───┬──┘
    │           │
    │ Auto      │ Manual
    │ Deploy    │ Approval
    ▼           ▼
  ┌───┐      ┌──────┐
  │Dev│      │ Prod │
  └───┘      └──────┘
```

---

## 📈 Pipeline Timeline

### Development Deploy

```
0min        5min        10min       15min
│───────────│───────────│───────────│
│           │           │           │
Push     Build &     Deploy      Complete
         Test        Lambda       & Notify
         
Total: ~10-15 minutes
```

### Production Deploy

```
0min    5min    10min   15min   20min   25min   30min
│───────│───────│───────│───────│───────│───────│
│       │       │       │       │       │       │
PR    Approval Build  Canary   Full   Tests  Complete
               Deploy 10%      100%
               
Total: ~25-30 minutes (including approval wait)
```

---

## 🔐 Security Layers

```
┌─────────────────────────────────────────────────┐
│              Security Layer 1                   │
│  Branch Protection (No direct commits)          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Security Layer 2                   │
│  Code Review (1-3 approvals required)           │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Security Layer 3                   │
│  Automated Security Scans                       │
│  • OWASP Dependency Check                       │
│  • Snyk                                         │
│  • Trivy (Docker)                               │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Security Layer 4                   │
│  Code Quality Gates                             │
│  • Static Analysis (PMD, SpotBugs)              │
│  • Style Check (Checkstyle)                     │
│  • Coverage (70% minimum)                       │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Security Layer 5                   │
│  Environment Segregation                        │
│  • Separate AWS accounts/credentials            │
│  • IAM least privilege                          │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Security Layer 6                   │
│  Production Safeguards                          │
│  • Manual approval                              │
│  • Canary deployment                            │
│  • Automatic rollback                           │
└─────────────────────────────────────────────────┘
```

---

## 🔄 Rollback Strategy

```
Production Deployment Failed?
         │
         ▼
    ┌─────────┐
    │ Detect  │
    │ Failure │
    └────┬────┘
         │
         ▼
    ┌──────────────┐
    │ Check Phase  │
    └──────┬───────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
Canary       Full Deploy
Phase        Phase
│             │
▼             ▼
Auto         Auto
Rollback     Rollback
│             │
└──────┬──────┘
       │
       ▼
  ┌─────────┐
  │ Restore │
  │ Previous│
  │ Version │
  └────┬────┘
       │
       ▼
  ┌─────────┐
  │ Verify  │
  │ Health  │
  └────┬────┘
       │
       ▼
  ┌─────────┐
  │ Notify  │
  │  Team   │
  └─────────┘
```

---

## 📊 Monitoring & Observability

```
┌─────────────────────────────────────────────────┐
│              Application Layer                  │
│  Lambda Function                                │
│  └─ New Relic APM                               │
│     • Transaction tracing                       │
│     • Error tracking                            │
│     • Custom metrics                            │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Infrastructure Layer               │
│  CloudWatch                                     │
│  • Lambda metrics (invocations, errors, etc)    │
│  • API Gateway metrics                          │
│  • Custom metrics                               │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Pipeline Layer                     │
│  GitHub Actions                                 │
│  • Workflow runs                                │
│  • Job success/failure                          │
│  • Build times                                  │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Alerting Layer                     │
│  • Slack notifications                          │
│  • Email alerts                                 │
│  • New Relic alerts                             │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Quality Gates Summary

| Gate | Tool | Threshold | Action on Fail |
|------|------|-----------|----------------|
| **Unit Tests** | JUnit | 100% pass | ❌ Block merge |
| **Coverage** | JaCoCo | 70% | ⚠️ Warn |
| **Style** | Checkstyle | Google Style | ⚠️ Warn |
| **Bugs** | SpotBugs | 0 high | ⚠️ Warn |
| **Vulnerabilities** | OWASP | CVSS < 8 | ⚠️ Warn |
| **Docker Scan** | Trivy | 0 critical | ⚠️ Warn |
| **Code Smells** | PMD | N/A | ⚠️ Warn |

---

Este diagrama representa a arquitetura completa do CI/CD implementado.
Use-o como referência visual para entender o fluxo completo do código
desde o desenvolvimento até produção.


@echo off
REM ============================================================================
REM Deploy Script with New Relic Integration (Windows)
REM ============================================================================

setlocal enabledelayedexpansion

echo ========================================
echo   ValidaPessoa Lambda - Deploy
echo   With New Relic Monitoring
echo ========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed
    exit /b 1
)
echo [OK] Java found

where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Maven is not installed
    exit /b 1
)
echo [OK] Maven found

where terraform >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Terraform is not installed
    exit /b 1
)
echo [OK] Terraform found

where aws >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: AWS CLI is not installed
    exit /b 1
)
echo [OK] AWS CLI found

echo.

REM ============================================================================
REM Step 1: Build Lambda
REM ============================================================================

echo Step 1: Building Lambda function...
cd LambdaValidaPessoa

echo Running Maven clean package...
call mvn clean package -DskipTests

if %errorlevel% neq 0 (
    echo ERROR: Maven build failed
    exit /b 1
)

echo [OK] Lambda JAR built successfully
dir target\ValidaPessoa-1.0.jar
echo.

cd ..

REM ============================================================================
REM Step 2: Validate New Relic Configuration
REM ============================================================================

echo Step 2: Validating New Relic configuration...

if "%NEW_RELIC_LICENSE_KEY%"=="" (
    echo WARNING: NEW_RELIC_LICENSE_KEY environment variable is not set
    echo New Relic monitoring will not be enabled
    set /p CONTINUE="Continue anyway? (y/n) "
    if /i not "!CONTINUE!"=="y" exit /b 1
) else (
    echo [OK] NEW_RELIC_LICENSE_KEY is set
)

echo.

REM ============================================================================
REM Step 3: Deploy Infrastructure
REM ============================================================================

echo Step 3: Deploying infrastructure with Terraform...
cd infra\terraform

if not exist terraform.tfvars (
    echo terraform.tfvars not found. Creating from example...
    copy terraform.tfvars.example terraform.tfvars
    echo Please edit terraform.tfvars with your configuration
    exit /b 1
)

echo Initializing Terraform...
terraform init

if %errorlevel% neq 0 (
    echo ERROR: Terraform init failed
    exit /b 1
)

echo Validating Terraform configuration...
terraform validate

if %errorlevel% neq 0 (
    echo ERROR: Terraform validation failed
    exit /b 1
)

echo Checking Terraform formatting...
terraform fmt -check

if %errorlevel% neq 0 (
    echo WARNING: Terraform files are not formatted. Running fmt...
    terraform fmt -recursive
)

echo Creating Terraform plan...
terraform plan -out=tfplan

if %errorlevel% neq 0 (
    echo ERROR: Terraform plan failed
    exit /b 1
)

set /p APPLY="Ready to apply Terraform changes. Continue? (y/n) "
if /i not "%APPLY%"=="y" (
    echo Deployment cancelled
    exit /b 0
)

terraform apply tfplan

if %errorlevel% neq 0 (
    echo ERROR: Terraform apply failed
    exit /b 1
)

echo [OK] Infrastructure deployed successfully
echo.

REM ============================================================================
REM Step 4: Get Outputs
REM ============================================================================

echo Step 4: Retrieving deployment information...

for /f "delims=" %%i in ('terraform output -raw api_gateway_url 2^>nul') do set API_URL=%%i
for /f "delims=" %%i in ('terraform output -raw lambda_function_arn 2^>nul') do set LAMBDA_ARN=%%i

echo.
echo ========================================
echo   Deployment Successful!
echo ========================================
echo.
echo API Gateway URL: %API_URL%
echo Lambda ARN: %LAMBDA_ARN%
echo.

REM ============================================================================
REM Step 5: Test Endpoint
REM ============================================================================

if not "%API_URL%"=="" (
    echo Step 5: Testing endpoint...
    echo.

    set TEST_CPF=11144477735

    echo Sending test request with CPF: !TEST_CPF!

    curl -X POST "%API_URL%/auth" ^
        -H "Content-Type: application/json" ^
        -d "{\"cpf\":\"!TEST_CPF!\"}"

    echo.
)

echo.

REM ============================================================================
REM Step 6: New Relic Dashboard Links
REM ============================================================================

if not "%NEW_RELIC_LICENSE_KEY%"=="" (
    echo ========================================
    echo   New Relic Monitoring
    echo ========================================
    echo.
    echo Your application is now being monitored by New Relic!
    echo.
    echo View your dashboard at:
    echo https://one.newrelic.com
    echo.
    echo Application Name: ValidaPessoa Lambda
    echo.
    echo Key Metrics to Monitor:
    echo   - Response Time
    echo   - Error Rate
    echo   - Throughput
    echo   - Memory Usage
    echo   - Database Query Performance
    echo.
)

REM ============================================================================
REM Cleanup
REM ============================================================================

cd ..\..

echo ========================================
echo   Deployment Complete!
echo ========================================

endlocal


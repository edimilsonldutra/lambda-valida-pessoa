# Remove BOM from Java files
$files = @(
    "LambdaValidaPessoa\src\main\java\lambdavalida\service\CustomerService.java",
    "LambdaValidaPessoa\src\main\java\lambdavalida\service\JWTService.java",
    "LambdaValidaPessoa\src\main\java\lambdavalida\monitoring\StructuredLogger.java",
    "LambdaValidaPessoa\src\main\java\lambdavalida\monitoring\MetricsCollector.java",
    "LambdaValidaPessoa\src\main\java\lambdavalida\service\DocumentoValidator.java"
)

foreach ($file in $files) {
    $fullPath = Join-Path $PSScriptRoot $file
    Write-Host "Processing: $fullPath"

    if (Test-Path $fullPath) {
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)

        # Check if file starts with UTF-8 BOM (EF BB BF)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Host "  -> Removing BOM"
            $newBytes = $bytes[3..($bytes.Length - 1)]
            [System.IO.File]::WriteAllBytes($fullPath, $newBytes)
        } else {
            Write-Host "  -> No BOM found"
        }
    } else {
        Write-Host "  -> File not found!"
    }
}

Write-Host "`nDone!"


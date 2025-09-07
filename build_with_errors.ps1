# Simple Build with Error Logging
# Uses Firefox's mach build but continues despite errors

param(
    [string]$ErrorsDir = "build_errors"
)

# Create errors directory
if (Test-Path $ErrorsDir) {
    Remove-Item $ErrorsDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ErrorsDir | Out-Null

Write-Host "Starting Infflow build with error logging..." -ForegroundColor Green
Write-Host "Errors will be saved to: $ErrorsDir" -ForegroundColor Yellow

# Set MozillaBuild environment variable
$env:MOZILLABUILD = "C:\mozilla-build"
Write-Host "Set MOZILLABUILD to: $env:MOZILLABUILD" -ForegroundColor Green

# Disable ccache to avoid "Cannot find ccache" errors
$env:CCACHE_DISABLE = "1"
Write-Host "Disabled ccache to avoid missing ccache errors" -ForegroundColor Green

# Change to engine directory
Set-Location engine

# Run build with live output and capture all output
Write-Host "Running build (continuing despite errors)..." -ForegroundColor Cyan

# Use PowerShell to run the build with live output and capture both stdout and stderr
$buildOutput = & ./mach build 2>&1 | Tee-Object -Variable buildOutput

# Save full output
$fullLogFile = Join-Path "..\$ErrorsDir" "full_build_log.txt"
$buildOutput | Out-File -FilePath $fullLogFile -Encoding UTF8

# Extract errors and warnings
$errorCount = 0
$warningCount = 0

# Find error lines (excluding ccache and other non-critical errors)
$errorLines = $buildOutput | Where-Object { 
    ($_ -match "error:" -or $_ -match "Error" -or $_ -match "ERROR") -and 
    $_ -notmatch "ccache" -and 
    $_ -notmatch "Cannot find ccache" -and
    $_ -notmatch "Fix above errors and then restart"
}
$warningLines = $buildOutput | Where-Object { 
    ($_ -match "warning:" -or $_ -match "Warning" -or $_ -match "WARNING") -and 
    $_ -notmatch "ccache"
}

# Save each error to individual file
foreach ($error in $errorLines) {
    $errorCount++
    $errorFile = Join-Path "..\$ErrorsDir" "error_$errorCount.txt"
    $error | Out-File -FilePath $errorFile -Encoding UTF8
    Write-Host "Saved error $errorCount" -ForegroundColor Red
}

# Save each warning to individual file  
foreach ($warning in $warningLines) {
    $warningCount++
    $warningFile = Join-Path "..\$ErrorsDir" "warning_$warningCount.txt"
    $warning | Out-File -FilePath $warningFile -Encoding UTF8
    Write-Host "Saved warning $warningCount" -ForegroundColor Yellow
}

# Create summary
$summaryFile = Join-Path "..\$ErrorsDir" "summary.txt"
$summary = @"
Infflow Build Error Summary
Generated: $(Get-Date)
Total Errors: $errorCount
Total Warnings: $warningCount

Files created:
- full_build_log.txt (complete build output)
- error_*.txt (individual error files)
- warning_*.txt (individual warning files)
- summary.txt (this file)

Build Status: Completed with $errorCount errors and $warningCount warnings
"@

$summary | Out-File -FilePath $summaryFile -Encoding UTF8

Write-Host "`nBuild completed!" -ForegroundColor Green
Write-Host "Total errors: $errorCount" -ForegroundColor Red
Write-Host "Total warnings: $warningCount" -ForegroundColor Yellow
Write-Host "Check '$ErrorsDir' folder for individual error files." -ForegroundColor Cyan

# Go back to original directory
Set-Location ..

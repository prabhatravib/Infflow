# Run Infflow Browser with Verbose Logging
# This script starts the Infflow browser with comprehensive logging options

Write-Host "Starting Infflow Browser with verbose logging..." -ForegroundColor Green

# Set environment variables
$env:MOZILLABUILD = "C:\mozilla-build"
$env:MOZ_LOG = "5"  # Maximum verbosity
$env:MOZ_LOG_FILE = "infflow_verbose.log"

# Change to engine directory
Set-Location engine

# Browser executable path
$browserPath = ".\obj-x86_64-pc-windows-msvc\dist\bin\infflow.exe"

# Check if browser exists
if (Test-Path $browserPath) {
    Write-Host "Found Infflow browser at: $browserPath" -ForegroundColor Green
    
    # Run browser with verbose options
    Write-Host "Starting browser with verbose logging..." -ForegroundColor Cyan
    Write-Host "Log file: infflow_verbose.log" -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop the browser" -ForegroundColor Yellow
    
    # Run the browser with various verbose flags
    & $browserPath `
        --verbose `
        --log-level debug `
        --jsconsole `
        --devtools `
        --safe-mode `
        --new-instance `
        --no-remote `
        --profile-manager `
        --debugger `
        --debugger-wait `
        --js-flags="--log-level=verbose" `
        2>&1 | Tee-Object -FilePath "browser_output.log"
} else {
    Write-Host "Browser not found at: $browserPath" -ForegroundColor Red
    Write-Host "Please build the browser first using: .\build_with_errors.ps1" -ForegroundColor Yellow
}

Write-Host "Browser session ended." -ForegroundColor Green

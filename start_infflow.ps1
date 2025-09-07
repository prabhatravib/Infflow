# Start Infflow Browser - Simple Launcher with Logging
# This script starts the Infflow browser in normal mode with organized logging

Write-Host "=== Starting Infflow Browser ===" -ForegroundColor Green
Write-Host "Starting at: $(Get-Date)" -ForegroundColor Cyan

# Change to engine directory
Set-Location engine

# Check if we're in the right directory
if (!(Test-Path "obj-x86_64-pc-windows-msvc\dist\bin\infflow.exe")) {
    Write-Host "Error: Browser executable not found!" -ForegroundColor Red
    Write-Host "Please make sure you're running this from the Infflow root directory." -ForegroundColor Yellow
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
    exit 1
}

# Create logs directory structure
$logsDir = "logs"
$today = Get-Date -Format "yyyy-MM-dd"
$sessionTime = Get-Date -Format "HH-mm-ss"
$sessionDir = "$logsDir\$today\$sessionTime"

# Create directory structure
if (!(Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
    Write-Host "Created logs directory: $logsDir" -ForegroundColor Yellow
}

if (!(Test-Path "$logsDir\$today")) {
    New-Item -ItemType Directory -Path "$logsDir\$today" | Out-Null
    Write-Host "Created today's log directory: $logsDir\$today" -ForegroundColor Yellow
}

if (!(Test-Path $sessionDir)) {
    New-Item -ItemType Directory -Path $sessionDir | Out-Null
    Write-Host "Created session log directory: $sessionDir" -ForegroundColor Yellow
}

# Set up logging environment variables
$env:MOZ_LOG = "3"  # Info level logging
$env:MOZ_LOG_FILE = "$sessionDir\infflow.log"
$env:MOZ_LOG_MODULES = "nsHttp:3,nsSocketTransport:3,nsHostResolver:3"

# Browser executable path
$browserPath = ".\obj-x86_64-pc-windows-msvc\dist\bin\infflow.exe"

Write-Host "Found Infflow browser at: $browserPath" -ForegroundColor Green
Write-Host "Logs will be saved to: $sessionDir" -ForegroundColor Cyan
Write-Host "Starting browser in normal mode..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the browser" -ForegroundColor Yellow
Write-Host ""

# Create a log file for this session
$sessionLogFile = "$sessionDir\session.log"
$sessionInfo = @"
=== Infflow Browser Session ===
Start Time: $(Get-Date)
Session Directory: $sessionDir
Browser Path: $browserPath
Log Level: Info (3)
"@

$sessionInfo | Out-File -FilePath $sessionLogFile -Encoding UTF8

# Start the browser with logging
try {
    Write-Host "Starting browser process..." -ForegroundColor Green
    
    # Start browser and capture output
    $browserProcess = Start-Process -FilePath $browserPath -PassThru -RedirectStandardOutput "$sessionDir\browser_output.log" -RedirectStandardError "$sessionDir\browser_error.log" -WindowStyle Normal
    
    # Log process information
    "Process ID: $($browserProcess.Id)" | Add-Content -Path $sessionLogFile
    "Process Start Time: $(Get-Date)" | Add-Content -Path $sessionLogFile
    
    Write-Host "Browser started with PID: $($browserProcess.Id)" -ForegroundColor Green
    Write-Host "Output log: $sessionDir\browser_output.log" -ForegroundColor Gray
    Write-Host "Error log: $sessionDir\browser_error.log" -ForegroundColor Gray
    Write-Host "Main log: $sessionDir\infflow.log" -ForegroundColor Gray
    
    # Wait for the browser process to exit
    $browserProcess.WaitForExit()
    
    # Log exit information
    "Process Exit Time: $(Get-Date)" | Add-Content -Path $sessionLogFile
    "Exit Code: $($browserProcess.ExitCode)" | Add-Content -Path $sessionLogFile
    
    Write-Host "Browser session ended with exit code: $($browserProcess.ExitCode)" -ForegroundColor Green
    
} catch {
    $errorMsg = "Error starting browser: $($_.Exception.Message)"
    Write-Host $errorMsg -ForegroundColor Red
    $errorMsg | Add-Content -Path $sessionLogFile
}

Write-Host "Session logs saved to: $sessionDir" -ForegroundColor Cyan
Write-Host "Infflow browser launcher finished at: $(Get-Date)" -ForegroundColor Green

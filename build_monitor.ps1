# Real-time Build Error Monitor
# Monitors build progress and shows errors as they occur

param(
    [string]$ErrorsDir = "build_errors_realtime"
)

# Create errors directory
if (Test-Path $ErrorsDir) {
    Remove-Item $ErrorsDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ErrorsDir | Out-Null

Write-Host "Starting real-time build monitor..." -ForegroundColor Green
Write-Host "Errors directory: $ErrorsDir" -ForegroundColor Yellow

# Start build process
$buildProcess = Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd engine; ./mach build" -RedirectStandardOutput "build_output.log" -RedirectStandardError "build_errors.log" -PassThru -NoNewWindow

$errorCount = 0
$lastPosition = 0

Write-Host "Monitoring build progress..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring (build will continue)" -ForegroundColor Yellow

try {
    while (!$buildProcess.HasExited) {
        Start-Sleep -Seconds 2
        
        # Check error log
        if (Test-Path "build_errors.log") {
            $errorContent = Get-Content "build_errors.log" -Raw
            $currentErrors = [regex]::Matches($errorContent, "error:", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            
            if ($currentErrors.Count -gt $errorCount) {
                $newErrors = $currentErrors.Count - $errorCount
                Write-Host "`n🚨 NEW ERRORS DETECTED: $newErrors" -ForegroundColor Red
                
                # Save new errors to individual files
                for ($i = $errorCount; $i -lt $currentErrors.Count; $i++) {
                    $errorFile = Join-Path $ErrorsDir "error_$($i + 1).txt"
                    $currentErrors[$i].Value | Out-File -FilePath $errorFile -Encoding UTF8
                }
                
                $errorCount = $currentErrors.Count
                Write-Host "Total errors so far: $errorCount" -ForegroundColor Red
            }
        }
        
        # Show progress
        if (Test-Path "build_output.log") {
            $outputContent = Get-Content "build_output.log" -Raw
            $currentPosition = $outputContent.Length
            
            if ($currentPosition -gt $lastPosition) {
                $newContent = $outputContent.Substring($lastPosition)
                $newLines = $newContent -split "`n" | Where-Object { $_.Trim() -ne "" }
                
                foreach ($line in $newLines) {
                    if ($line -match "TIER:|Compiling|Finished") {
                        Write-Host $line -ForegroundColor Green
                    } elseif ($line -match "error:") {
                        Write-Host $line -ForegroundColor Red
                    } elseif ($line -match "warning:") {
                        Write-Host $line -ForegroundColor Yellow
                    }
                }
                
                $lastPosition = $currentPosition
            }
        }
    }
} catch {
    Write-Host "`nMonitoring stopped by user." -ForegroundColor Yellow
}

Write-Host "`nBuild process completed!" -ForegroundColor Green
Write-Host "Check '$ErrorsDir' for individual error files." -ForegroundColor Yellow

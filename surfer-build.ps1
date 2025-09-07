$repo = "C:\Users\prabh\OneDrive\Documents\GitHub\Infflow"
$src  = Join-Path $repo "engine\mozconfig"
$dst  = Join-Path $repo "engine\mozconfig.clean"

# Re-sanitize each time in case Surfer rewrites the file
$bytes = Get-Content -Raw -Encoding Byte $src
$text  = [Text.Encoding]::UTF8.GetString($bytes)
$text  = $text -replace "`r`n","`n" -replace "`r","`n"
if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
[IO.File]::WriteAllText($dst, $text, (New-Object Text.UTF8Encoding($false)))

$env:MOZCONFIG = $dst
Write-Host "Using clean mozconfig: $env:MOZCONFIG"
npx @zen-browser/surfer build

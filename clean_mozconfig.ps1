$src = "C:\Users\prabh\OneDrive\Documents\GitHub\Infflow\engine\mozconfig"
$dst = "C:\Users\prabh\OneDrive\Documents\GitHub\Infflow\engine\mozconfig.clean"

# Read raw bytes and normalize to LF, drop BOM if present
$bytes = Get-Content -Raw -Encoding Byte $src
$text  = [Text.Encoding]::UTF8.GetString($bytes)
$text  = $text -replace "`r`n","`n" -replace "`r","`n"
if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }

# Disable sccache to avoid path issues
$text = $text -replace "ac_add_options --with-ccache=.*", "# ac_add_options --with-ccache disabled due to path issues"
$text = $text -replace "ac_add_options --enable-bootstrap=-sccache", "# ac_add_options --enable-bootstrap=-sccache disabled"

# Write UTF-8 without BOM
$utf8NoBom = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($dst, $text, $utf8NoBom)

Write-Host "Clean mozconfig created at: $dst"

# Tell Mozilla's build system to use the clean file
$env:MOZCONFIG = $dst
Write-Host "MOZCONFIG set to: $env:MOZCONFIG"

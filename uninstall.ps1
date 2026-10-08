# Quran in Word - Uninstaller Script
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step($msg) { Write-Host "`n[>] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }

# ── 1. Remove sideloaded add-in from Word ─────────────────────────
Write-Step "Menghapus add-in dari Word..."
npx --yes office-addin-sideload --manifest "$ProjectRoot\manifest.xml" --remove 2>&1 | Out-Host
Write-OK "Add-in dihapus dari Word (jika ada)."

# ── 2. Remove dev certificate ─────────────────────────────────────
Write-Step "Menghapus SSL certificate..."
npx --yes office-addin-dev-certs uninstall 2>&1 | Out-Host
Write-OK "Certificate dihapus."

# ── 3. Clean build artifacts ──────────────────────────────────────
Write-Step "Membersihkan build artifacts..."
$distPath = "$ProjectRoot\dist"
if (Test-Path $distPath) { Remove-Item $distPath -Recurse -Force }
Write-OK "Build artifacts dibersihkan."

Write-Host "`nUninstall selesai." -ForegroundColor Green
exit 0

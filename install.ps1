# Quran in Office - Installer Script
# One-click setup: Node.js check, npm install, cert, build, sideload

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

function Write-Step($msg) { Write-Host "`n[>] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# ── 1. Check Node.js ──────────────────────────────────────────────
Write-Step "Cek Node.js..."
$nodeExe = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeExe) {
    Write-Host "    Node.js belum terpasang. Menginstall via winget..."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $nodeExe = Get-Command node -ErrorAction SilentlyContinue
        if (-not $nodeExe) {
            Write-Err "Node.js gagal terinstall. Silakan install manual dari https://nodejs.org"
            exit 1
        }
    } else {
        Write-Err "winget tidak tersedia. Silakan install Node.js manual dari https://nodejs.org"
        exit 1
    }
}
$nodeVer = node --version
Write-OK "Node.js $nodeVer ditemukan."

# ── 2. npm install ────────────────────────────────────────────────
Write-Step "Install dependencies (npm install)..."
if (-not (Test-Path "$ProjectRoot\node_modules")) {
    npm install --silent 2>&1 | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Err "npm install gagal."
        exit 1
    }
} else {
    Write-Host "    node_modules sudah ada, skip."
}
Write-OK "Dependencies siap."

# ── 3. Self-signed certificate ────────────────────────────────────
Write-Step "Setup SSL certificate untuk HTTPS..."
$certUtil = Get-Command npx -ErrorAction SilentlyContinue
if ($certUtil) {
    npx --yes office-addin-dev-certs install --machine 2>&1 | Out-Host
    if ($LASTEXITCODE -eq 0) {
        Write-OK "SSL certificate terpasang dan dipercaya."
    } else {
        Write-Host "    office-addin-dev-certs tidak tersedia, skip cert." -ForegroundColor Yellow
    }
} else {
    Write-Host "    npx tidak tersedia, skip cert." -ForegroundColor Yellow
}

# ── 4. Build project ──────────────────────────────────────────────
Write-Step "Build project (npm run build)..."
npm run build 2>&1 | Out-Host
if ($LASTEXITCODE -ne 0) {
    Write-Err "Build gagal. Periksa error di atas."
    exit 1
}
Write-OK "Build berhasil."

# ── 5. Sideload manifest into Word ────────────────────────────────
Write-Step "Sideload manifest ke Microsoft Word atau PowerPoint..."
npx --yes office-addin-sideload --manifest "$ProjectRoot\manifest.xml" 2>&1 | Out-Host
if ($LASTEXITCODE -eq 0) {
    Write-OK "Add-in disideload ke Word dan PowerPoint."
} else {
    Write-Host "    Sideload otomatis gagal. Anda bisa sideload manual:" -ForegroundColor Yellow
    Write-Host "    Word/PowerPoint > Insert > My Add-ins > Upload My Add-in > pilih manifest.xml" -ForegroundColor Yellow
}

# ── 6. Create start-server script ─────────────────────────────────
$startScript = @"
@echo off
chcp 65001 >nul 2>&1
title Quran in Office - Server
echo.
echo  Menjalankan server Quran in Office...
echo  Buka Microsoft Word atau PowerPoint dan gunakan add-in Quran.
echo  Tekan Ctrl+C untuk berhenti.
echo.
cd /d "$ProjectRoot"
npx --yes serve dist -l 3000 --ssl-cert (office-addin-dev-certs cert) --ssl-key (office-addin-dev-certs key)
"@
# Fallback simpler start script
$startBat = @"
@echo off
chcp 65001 >nul 2>&1
title Quran in Office - Server
echo.
echo  Menjalankan server Quran in Office...
echo  Buka Microsoft Word atau PowerPoint dan gunakan add-in Quran.
echo  Tekan Ctrl+C untuk berhenti.
echo.
cd /d "$ProjectRoot"
npm run dev
"@
Set-Content -Path "$ProjectRoot\start-server.bat" -Value $startBat -Encoding UTF8
Write-OK "start-server.bat dibuat."

# ── Done ──────────────────────────────────────────────────────────
Write-Host "`n"
Write-Host "  ═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Instalasi selesai!" -ForegroundColor Green
Write-Host ""
Write-Host "  Langkah selanjutnya:" -ForegroundColor White
Write-Host "  1. Jalankan start-server.bat" -ForegroundColor White
Write-Host "  2. Buka Microsoft Word atau PowerPoint" -ForegroundColor White
Write-Host "  3. Insert > My Add-ins > tab 'Developer Add-ins' > 'Quran in Office' > Add" -ForegroundColor White
Write-Host ""
Write-Host "  ═══════════════════════════════════════════" -ForegroundColor Green

exit 0

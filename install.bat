@echo off
chcp 65001 >nul 2>&1
title Quran in Office - Installer
color 0A

echo.
echo  ╔═══════════════════════════════════════════════╗
echo  ║        Quran in Office - One-Click Installer     ║
echo  ╚═══════════════════════════════════════════════╝
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell tidak ditemukan. Windows 10+ diperlukan.
    pause
    exit /b 1
)

:: Run the PowerShell installer
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if %errorlevel% equ 0 (
    echo.
    echo  ╔═══════════════════════════════════════════════╗
    echo  ║  ✓ Instalasi selesai!                         ║
    ║  Buka Microsoft Word atau PowerPoint, add-in sudah tersedia.   ║
    ║  Jalankan start-server.bat untuk memulai.       ║
    echo  ╚═══════════════════════════════════════════════╝
) else (
    echo.
    echo  ╔═══════════════════════════════════════════════╗
    echo  ║  ✗ Instalasi gagal. Periksa error di atas.    ║
    echo  ╚═══════════════════════════════════════════════╝
)

echo.
pause

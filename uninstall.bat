@echo off
chcp 65001 >nul 2>&1
title Quran in Office - Uninstaller
color 0C

echo.
echo  ╔═══════════════════════════════════════════════╗
echo  ║       Quran in Office - Uninstaller              ║
echo  ╚═══════════════════════════════════════════════╝
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"

echo.
pause

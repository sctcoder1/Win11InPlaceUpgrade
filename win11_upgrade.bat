@echo off
title Windows 11 In-Place Upgrade (Auto Setup)
color 0A
echo.
echo ===========================================================
echo       Windows 11 In-Place Upgrade - Automated Installer
echo ===========================================================
echo.

:: --- Variables ---
set "root=C:\Win11Upgrade"
set "zip=%root%\Win11InPlaceUpgrade.zip"
set "url=https://github.com/kountilya/Win11InPlaceUpgrade/archive/refs/heads/main.zip"
set "extractdir=%root%\Win11InPlaceUpgrade-main"

:: --- Create main folder if missing ---
if not exist "%root%" (
    echo Creating %root% ...
    mkdir "%root%"
)

:: --- Download package only if it doesn't exist ---
if exist "%zip%" (
    echo Found existing ZIP file at %zip%.
    echo Skipping download.
) else (
    echo.
    echo Downloading Windows 11 Upgrade package...
    powershell -ExecutionPolicy Bypass -NoProfile -Command ^
        "Invoke-WebRequest -Uri '%url%' -OutFile '%zip%' -UseBasicParsing"
)

:: --- Verify download ---
if not exist "%zip%" (
    echo ❌ Download failed! Check your internet connection or Sophos logs.
    pause
    exit /b 1
)

:: --- Extract package ---
echo.
echo Extracting package to %root% ...
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "Expand-Archive -Path '%zip%' -DestinationPath '%root%' -Force"

:: --- Keep ZIP file for reuse ---
echo.
echo Keeping ZIP file for future use...
echo.

:: --- Locate Install.ps1 ---
set "installps=%extractdir%\Install.ps1"
if not exist "%installps%" (
    echo ❌ ERROR: Install.ps1 not found at expected path:
    echo    %installps%
    echo.
    echo Check folder structure under C:\Win11Upgrade\
    pause
    exit /b 1
)

:: --- Run PowerShell installer ---
echo ===========================================================
echo   Running Windows 11 Upgrade PowerShell script...
echo   Path: %installps%
echo ===========================================================
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%installps%"

echo.
echo ===========================================================
echo   Windows 11 Upgrade process started (if supported).
echo   The system may reboot automatically once setup launches.
echo ===========================================================
pause
exit /b 0

@echo off
title Windows 11 Upgrade Cleanup
color 0A
setlocal enabledelayedexpansion

set "upgdir=C:\Win11Upgrade"
set "log=%upgdir%\Cleanup_RunLog.txt"
if not exist "%upgdir%" mkdir "%upgdir%" >nul 2>&1

echo =========================================================== >> "%log%"
echo Starting Windows 11 Upgrade Cleanup at %date% %time% >> "%log%"
echo =========================================================== >> "%log%"

:: --- Ensure admin privileges ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator rights... >> "%log%"
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: --- Remove upgrade working folder ---
echo Removing %upgdir% ... >> "%log%"
if exist "%upgdir%" (
    rmdir /s /q "%upgdir%"
    echo %upgdir% removed. >> "%log%"
) else (
    echo %upgdir% not found, skipping. >> "%log%"
)

:: --- Uninstall Windows 11 Installation Assistant ---
echo. >> "%log%"
echo Uninstalling Windows 11 Installation Assistant... >> "%log%"
if exist "C:\Program Files (x86)\WindowsInstallationAssistant\Windows10UpgraderApp.exe" (
    start "" /wait "C:\Program Files (x86)\WindowsInstallationAssistant\Windows10UpgraderApp.exe" /SunValley /ForceUninstall
    echo Uninstall command executed. >> "%log%"
) else (
    echo Windows 11 Installation Assistant not found. >> "%log%"
)

:: --- Remove leftover folders ---
echo. >> "%log%"
echo Cleaning up leftover folders... >> "%log%"
rd /s /q "C:\Program Files\Windows 11 Installation Assistant" 2>nul
rd /s /q "C:\Program Files (x86)\Windows 11 Installation Assistant" 2>nul
rd /s /q "%ProgramData%\Microsoft\Windows\Windows 11 Installation Assistant" 2>nul
rd /s /q "C:\Program Files (x86)\WindowsInstallationAssistant" 2>nul
echo Residual folders removed (if any). >> "%log%"

:: --- Schedule self-deletion on reboot ---
echo. >> "%log%"
echo Scheduling self-deletion... >> "%log%"
set "self=%~f0"
schtasks /create /tn "CleanupDeleteSelf" /sc onstart /ru SYSTEM /rl HIGHEST ^
 /tr "cmd /c del /f /q \"%self%\" & schtasks /delete /tn CleanupDeleteSelf /f" >nul 2>&1
echo Self-deletion scheduled. >> "%log%"

:: --- Finalize and reboot ---
echo. >> "%log%"
echo Cleanup complete. System will reboot in 15 seconds. >> "%log%"
echo =========================================================== >> "%log%"

timeout /t 15 /nobreak >nul
shutdown /r /t 5 /c "Windows 11 Upgrade cleanup complete. Rebooting..."

endlocal
exit /b 0

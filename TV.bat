# Windows 11 In-Place Upgrade – TeamViewer version (handoff to user session)

$repo   = 'https://codeload.github.com/sctcoder1/Win11InPlaceUpgrade/zip/refs/heads/main'
$root   = 'C:\Win11Upgrade'
$zip    = Join-Path $root 'Win11InPlaceUpgrade.zip'
$extract= Join-Path $root 'Win11InPlaceUpgrade-main'
$bat    = Join-Path $extract 'Win11_Upgrade2.bat'

New-Item -ItemType Directory -Force -Path $root | Out-Null
Invoke-WebRequest -Uri $repo -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $root -Force
Remove-Item $zip -Force

if (!(Test-Path $bat)) {
    Write-Host "❌ $bat not found" ; exit 1
}

# --- Detect logged-in user session ---
$userInfo = (Get-CimInstance Win32_ComputerSystem)
if (-not $userInfo.UserName) {
    Write-Host "⚠️ No user logged in. Scheduling run at next logon..."
    schtasks /create /tn "Win11_Upgrade_UserRun" /tr $bat /sc onlogon /rl highest /f | Out-Null
    exit 0
}

# Parse user and session ID
$session = (quser | Select-String "Active").ToString().Split() | Select-Object -Last 1
$sessionId = ($session -as [int])

Write-Host "👤 Detected logged-in session ID: $sessionId"

# --- Launch in user’s interactive session ---
Start-Process "cmd.exe" -ArgumentList "/c psexec -i $sessionId -d cmd /c `"$bat`"" -WindowStyle Hidden
Write-Host "🚀 Launched Windows 11 Upgrade in user session."

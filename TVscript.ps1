# Windows 11 In-Place Upgrade - TeamViewer Deployment (System Context)

$repo   = 'https://codeload.github.com/sctcoder1/Win11InPlaceUpgrade/zip/refs/heads/main'
$root   = 'C:\Win11Upgrade'
$zip    = Join-Path $root 'Win11InPlaceUpgrade.zip'
$extract= Join-Path $root 'Win11InPlaceUpgrade-main'
$bat    = Join-Path $extract 'Win11_Upgrade2.bat'  # Modified as requested

# --- Create working folder ---
New-Item -ItemType Directory -Force -Path $root | Out-Null

Write-Host "📦 Downloading Windows 11 In-Place Upgrade package..."
Invoke-WebRequest -Uri $repo -OutFile $zip -UseBasicParsing

Write-Host "📂 Extracting package..."
Expand-Archive -Path $zip -DestinationPath $root -Force
Remove-Item $zip -Force

# --- Verify file existence ---
if (!(Test-Path $bat)) {
    Write-Host "❌ ERROR: $bat not found. Exiting..."
    Exit 1
}

# --- Run the upgrade batch file as SYSTEM (TeamViewer runs under SYSTEM) ---
Write-Host "🚀 Starting Windows 11 Upgrade..."
Start-Process -FilePath "cmd.exe" -ArgumentList "/c start /min `"$bat`"" -Verb RunAs

Write-Host "✅ Windows 11 In-Place Upgrade initiated successfully."
Exit 0

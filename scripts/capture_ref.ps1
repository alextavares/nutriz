param(
  [string[]] $Serial,
  [string] $OutDir = "",
  [string] $FileName = "ref"
)

$ErrorActionPreference = 'Stop'

# Resolve adb path
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (-not (Test-Path $adb)) {
  Write-Error "adb.exe not found at: $adb"
}

# Default output dir => repo test/goldens/reference
if ([string]::IsNullOrWhiteSpace($OutDir)) {
  $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  $OutDir = Join-Path $repoRoot 'test\goldens\reference'
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

function Get-OnlineDevices() {
  & $adb devices | Select-Object -Skip 1 |
    Where-Object { $_ -match "\tdevice$" } |
    ForEach-Object { ($_ -split "\s+")[0] }
}

if (-not $Serial -or $Serial.Count -eq 0) {
  $Serial = @(Get-OnlineDevices)
}

if ($Serial.Count -eq 0) {
  Write-Error 'No online devices found. Start an emulator and try again.'
}

Write-Host "Capturing from devices: $($Serial -join ', ')"

$i = 0
foreach ($s in $Serial) {
  $i++
  $suffix = if ($Serial.Count -gt 1) { "_${i}" } else { "" }
  $outFile = Join-Path $OutDir ("$FileName$suffix.png")
  Write-Host "Saving: $outFile"
  # Use cmd redirection to avoid PowerShell stream quirks
  $cmd = '"' + $adb + '" -s ' + $s + ' exec-out screencap -p > ' + '"' + $outFile + '"'
  cmd /c $cmd
}

Write-Host "Done. Files in: $OutDir"


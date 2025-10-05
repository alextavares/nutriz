param(
  [Parameter(Mandatory=$true)][int]$X,
  [Parameter(Mandatory=$true)][int]$Y,
  [string]$Serial = $env:ADB_SERIAL,
  [string]$Adb = $env:ADB_PATH
)

if (-not $Adb -or $Adb.Trim() -eq "") { $Adb = "adb" }
if (-not $Serial -or $Serial.Trim() -eq "") { $Serial = "emulator-5556" }

& $Adb -s $Serial shell input tap $X $Y
exit $LASTEXITCODE


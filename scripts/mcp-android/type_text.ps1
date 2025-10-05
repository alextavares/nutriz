param(
  [Parameter(Mandatory=$true)][string]$Text,
  [string]$Serial = $env:ADB_SERIAL,
  [string]$Adb = $env:ADB_PATH
)

if (-not $Adb -or $Adb.Trim() -eq "") { $Adb = "adb" }
if (-not $Serial -or $Serial.Trim() -eq "") { $Serial = "emulator-5556" }

# Replace spaces with %s for adb input
$escaped = $Text -replace " ", "%s"
& $Adb -s $Serial shell input text $escaped
exit $LASTEXITCODE


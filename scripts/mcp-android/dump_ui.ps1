param(
  [string]$Serial = $env:ADB_SERIAL,
  [string]$Adb = $env:ADB_PATH
)

if (-not $Adb -or $Adb.Trim() -eq "") { $Adb = "adb" }
if (-not $Serial -or $Serial.Trim() -eq "") { $Serial = "emulator-5556" }

& $Adb -s $Serial shell uiautomator dump 1>$null 2>$null
& $Adb -s $Serial shell cat /sdcard/window_dump.xml
exit $LASTEXITCODE


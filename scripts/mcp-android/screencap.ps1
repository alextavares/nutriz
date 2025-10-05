param(
  [string]$Serial = $env:ADB_SERIAL,
  [string]$Adb = $env:ADB_PATH
)

if (-not $Adb -or $Adb.Trim() -eq "") { $Adb = "adb" }
if (-not $Serial -or $Serial.Trim() -eq "") { $Serial = "emulator-5556" }

$tmp = [System.IO.Path]::GetTempFileName()
try {
  & $Adb -s $Serial exec-out screencap -p > $tmp
  if ($LASTEXITCODE -ne 0) { throw "adb screencap failed (code $LASTEXITCODE)" }
  $bytes = [System.IO.File]::ReadAllBytes($tmp)
  $b64 = [System.Convert]::ToBase64String($bytes)
  Write-Output $b64
} finally {
  try { Remove-Item -Force -ErrorAction SilentlyContinue $tmp } catch {}
}


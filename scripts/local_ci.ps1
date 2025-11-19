Param(
  [ValidateSet('all','fasting','banner','coverage')]
  [string]$Scope = 'all',
  [switch]$Build,
  [switch]$UploadCodecov
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Step($name, [scriptblock]$action) {
  Write-Host "==> $name" -ForegroundColor Cyan
  & $action
}

function Have-Cmd($cmd) {
  return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

Step 'Flutter version' { flutter --version }

Step 'Dependencies' {
  flutter pub get
  if (Test-Path 'l10n.yaml') { flutter gen-l10n }
}

Step 'Analyze' { flutter analyze }

switch ($Scope) {
  'all' {
    Step 'Tests (all + coverage)' { flutter test --coverage --reporter expanded }
  }
  'coverage' {
    Step 'Tests (coverage only)' { flutter test --coverage --reporter expanded }
  }
  'fasting' {
    Step 'Tests (fasting)' { flutter test test/fasting_storage_test.dart --reporter expanded }
  }
  'banner' {
    Step 'Tests (banner)' { flutter test test/daily_dashboard_fasting_banner_test.dart --reporter expanded }
  }
}

# Try to generate HTML coverage if tools are present
if (Test-Path 'coverage/lcov.info') {
  if (Have-Cmd 'genhtml') {
    Step 'Generate HTML coverage' { genhtml -o coverage/html coverage/lcov.info }
  } else {
    Write-Host 'genhtml not found; skipping HTML coverage. You can install lcov to enable this.' -ForegroundColor Yellow
  }
}

# Optional Codecov upload
if ($UploadCodecov -and (Test-Path 'coverage/lcov.info')) {
  if (-not $env:CODECOV_TOKEN) {
    Write-Host 'CODECOV_TOKEN not set; skipping Codecov upload.' -ForegroundColor Yellow
  } else {
    $uploader = Join-Path $PWD 'codecov.exe'
    if (-not (Test-Path $uploader)) {
      Invoke-WebRequest -Uri 'https://uploader.codecov.io/latest/windows/codecov.exe' -OutFile $uploader
    }
    Step 'Upload coverage to Codecov' { & $uploader -t $env:CODECOV_TOKEN -f 'coverage/lcov.info' -F 'flutter' }
  }
}

if ($Build) {
  Step 'Build debug APK' { flutter build apk --debug }
}

Write-Host 'All done.' -ForegroundColor Green


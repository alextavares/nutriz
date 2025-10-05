#Requires -Version 5.1
<#!
.SYNOPSIS
  Filtra o Logcat do Android para o app alvo e mostra apenas linhas relevantes (Flutter/overflow/exceptions).

.PARAMETER PackageName
  Nome do pacote do app (default: com.nutritracker.app).

.PARAMETER Pattern
  Regex para filtrar as mensagens (default cobre RenderFlex/overflow/EXCEPTION/Flutter/AI/Camera).

.PARAMETER Once
  Usa dump (-d) e sai após imprimir (snapshot). Sem isso, fica seguindo a saída ao vivo.

.PARAMETER NoPid
  Não filtra por PID. Útil se o app reinicia e troca o PID.

.PARAMETER OutFile
  Caminho de arquivo para salvar (além de exibir). Usa Tee-Object.

.EXAMPLE
  ./scripts/log_filter.ps1

.EXAMPLE
  ./scripts/log_filter.ps1 -PackageName com.nutritracker.app -OutFile logs/logcat_filtered.txt

.EXAMPLE
  ./scripts/log_filter.ps1 -Pattern "(?i)(overflowed by|EXCEPTION|relevant error-causing widget)"

#>

param(
  [string]$PackageName = 'com.nutritracker.app',
  [string]$Pattern = '(?i)(RenderFlex|overflowed by|EXCEPTION CAUGHT|relevant error-causing widget|The following assertion was thrown|during layout|I/flutter|E/flutter|AiFoodDetection|Camera)',
  [switch]$Once,
  [switch]$NoPid,
  [string]$OutFile,
  [string]$Device
)

function Get-AdbPid([string]$pkg) {
  try {
    $p = & adb shell pidof -s $pkg 2>$null
    if ([string]::IsNullOrWhiteSpace($p)) { return $null }
    return $p.Trim()
  } catch { return $null }
}

function Start-LogcatStream {
  param(
    [string]$TargetPid,
    [string]$pattern,
    [switch]$dump,
    [string]$out,
    [string]$device
  )

  $cmd = @()
  if ($device) { $cmd += '-s'; $cmd += $device }
  $cmd += @('logcat','-v','time')
  if ($dump) { $cmd += '-d' }
  if ($TargetPid) { $cmd += "--pid=$TargetPid" }

  Write-Host "[i] Running: adb $($cmd -join ' ')" -ForegroundColor Cyan
  if ($out) {
    & adb @cmd | Select-String -Pattern $pattern | Tee-Object -FilePath $out
  } else {
    & adb @cmd | Select-String -Pattern $pattern
  }
}

# Ensure adb exists
try { & adb version | Out-Null } catch {
  Write-Error 'adb não encontrado no PATH. Instale o Android Platform-Tools e tente novamente.'
  exit 1
}

$TargetPid = $null
if (-not $NoPid) {
  $TargetPid = Get-AdbPid -pkg $PackageName
  if (-not $TargetPid) {
    Write-Warning "PID não encontrado para '$PackageName'. Continuando sem --pid (use -NoPid para suprimir este aviso)."
  } else {
    Write-Host "[i] Filtrando por PID=$TargetPid do pacote '$PackageName'" -ForegroundColor Green
  }
} else {
  Write-Host "[i] Sem filtro de PID (opção -NoPid)" -ForegroundColor Yellow
}

$dump = $false
if ($Once) { $dump = $true }

if (-not $Device) {
  # If multiple devices are connected, show a quick hint
  try {
    $lines = & adb devices 2>$null | Select-String -Pattern '\tdevice$'
    if ($lines.Count -gt 1) {
      Write-Warning "Múltiplos devices/emuladores detectados. Use -Device <serial> (ex.: emulator-5554)."
      & adb devices -l
    }
  } catch {}
}

Start-LogcatStream -TargetPid $TargetPid -pattern $Pattern -dump:$dump -out $OutFile -device $Device

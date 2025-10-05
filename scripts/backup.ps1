Param(
    [string]$Tag = "",
    [switch]$Open
)

# Gera um ZIP dos arquivos rastreados pelo Git.
# Se um tag for informado, exporta aquele tag; senão, exporta HEAD.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir '..')
Set-Location $RepoRoot

& git --version | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Error "git não encontrado no PATH"; exit 1 }

$ref = $Tag
if (-not $ref -or $ref.Trim().Length -eq 0) { $ref = 'HEAD' }

$backupDir = Join-Path $RepoRoot 'backups'
if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }

if (-not $Tag) {
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $Tag = "snapshot-$ts"
}

$zipPath = Join-Path $backupDir ("$Tag.zip")
& git archive --format=zip --output "$zipPath" $ref
Write-Host "Backup salvo em: $zipPath"

if ($Open) { Invoke-Item $backupDir }

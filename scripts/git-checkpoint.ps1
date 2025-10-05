Param(
    [string]$Message = "checkpoint",
    [string]$Tag = "",
    [switch]$Zip
)

$ErrorActionPreference = 'Stop'

# Resolve repo root (folder that contains this script)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir '..')
Set-Location $RepoRoot

& git --version | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Error "git não encontrado no PATH"; exit 1 }

# Init repo if needed
if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    Write-Host "Inicializando repositório git..."
    & git init | Out-Null
}

# Stage all changes
& git add -A

# Commit only if there are staged changes
$status = & git status --porcelain
if ($status) {
    & git commit -m $Message | Out-Null
} else {
    Write-Host "Nenhuma alteração para commit. Criando checkpoint com HEAD atual."
}

# Tag name if not provided
if (-not $Tag -or $Tag.Trim().Length -eq 0) {
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $Tag = "stable-$ts"
}

& git tag -a $Tag -m $Message
Write-Host "Checkpoint criado: tag $Tag"

if ($Zip) {
    $backupDir = Join-Path $RepoRoot 'backups'
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $zipPath = Join-Path $backupDir ("$Tag.zip")
    & git archive --format=zip --output "$zipPath" $Tag
    Write-Host "Backup gerado: $zipPath"
}

Write-Host "OK. Use 'git switch -c <branch>' para criar uma branch de trabalho."

# Safe Git Time Travel Script
# Este script permite testar versões anteriores do app sem perder o trabalho atual

param(
    [Parameter(Mandatory=$false)]
    [string]$TargetCommit = "76ce357",  # Commit antes da refatoração

    [Parameter(Mandatory=$false)]
    [switch]$Return  # Use para voltar ao estado atual
)

$BackupBranch = "backup/current-work-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$StashName = "safe-time-travel-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Save-CurrentWork {
    Write-Host "🔒 Salvando trabalho atual..." -ForegroundColor Cyan

    # Criar branch de backup
    git branch $BackupBranch
    Write-Host "✅ Branch de backup criado: $BackupBranch" -ForegroundColor Green

    # Fazer stash das mudanças
    git stash push -u -m $StashName
    Write-Host "✅ Mudanças salvas em stash: $StashName" -ForegroundColor Green

    # Mostrar informações
    Write-Host "`n📋 Informações de backup:" -ForegroundColor Yellow
    Write-Host "   Branch atual: $(git branch --show-current)" -ForegroundColor White
    Write-Host "   Commit atual: $(git rev-parse --short HEAD)" -ForegroundColor White
    Write-Host "   Branch backup: $BackupBranch" -ForegroundColor White
    Write-Host "   Stash: $StashName" -ForegroundColor White
}

function Go-ToPast {
    param([string]$Commit)

    Write-Host "`n⏪ Voltando para commit $Commit..." -ForegroundColor Cyan
    git checkout $Commit

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Checkout realizado com sucesso!" -ForegroundColor Green
        Write-Host "`n📱 Agora você pode testar o app:" -ForegroundColor Yellow
        Write-Host "   flutter run" -ForegroundColor White
        Write-Host "`n⚠️  Para voltar ao estado atual, execute:" -ForegroundColor Yellow
        Write-Host "   .\scripts\safe_time_travel.ps1 -Return" -ForegroundColor White
    } else {
        Write-Host "❌ Erro no checkout!" -ForegroundColor Red
    }
}

function Return-ToPresent {
    Write-Host "`n⏩ Retornando ao estado atual..." -ForegroundColor Cyan

    # Voltar para a branch original
    $originalBranch = "chore/release-notes/i18n-notifications"
    git checkout $originalBranch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Voltou para branch: $originalBranch" -ForegroundColor Green

        # Listar stashes disponíveis
        Write-Host "`n📋 Stashes disponíveis:" -ForegroundColor Yellow
        git stash list | Select-String "safe-time-travel"

        Write-Host "`n⚠️  Para restaurar suas mudanças:" -ForegroundColor Yellow
        Write-Host "   git stash list  # Ver todos os stashes" -ForegroundColor White
        Write-Host "   git stash pop stash@{N}  # Restaurar stash específico" -ForegroundColor White

        Write-Host "`n📋 Branches de backup disponíveis:" -ForegroundColor Yellow
        git branch | Select-String "backup/current-work"
    } else {
        Write-Host "❌ Erro ao retornar!" -ForegroundColor Red
    }
}

function Show-Comparison {
    Write-Host "`n📊 Comparação de arquivos modificados:" -ForegroundColor Cyan
    Write-Host "Arquivos que mudaram desde o commit $TargetCommit :" -ForegroundColor Yellow
    git diff --name-status $TargetCommit HEAD | Where-Object { $_ -match '\.(dart|yaml)$' }
}

# Main execution
Write-Host "🚀 Safe Git Time Travel" -ForegroundColor Magenta
Write-Host "=====================`n" -ForegroundColor Magenta

if ($Return) {
    Return-ToPresent
} else {
    # Verificar se há mudanças não commitadas
    $hasChanges = git status --porcelain

    if ($hasChanges) {
        Write-Host "⚠️  Você tem mudanças não commitadas" -ForegroundColor Yellow
        $response = Read-Host "Deseja salvar essas mudanças antes de continuar? (S/N)"

        if ($response -eq 'S' -or $response -eq 's') {
            Save-CurrentWork
            Go-ToPast -Commit $TargetCommit
        } else {
            Write-Host "❌ Operação cancelada. Commit ou descarte suas mudanças primeiro." -ForegroundColor Red
        }
    } else {
        Go-ToPast -Commit $TargetCommit
    }

    Show-Comparison
}

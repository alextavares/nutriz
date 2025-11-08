# Script para auditar strings hardcoded em inglês
# Use: .\scripts\audit_i18n.ps1

Write-Host "🔍 Auditando strings i18n no código..." -ForegroundColor Cyan

$libPath = "lib"
$excludeDirs = @("l10n", "generated")
$patterns = @(
    '"(?!.*\{)([A-Z][a-z]+ )+[a-z]+.*"',  # Frases em inglês
    "'(?!.*\{)([A-Z][a-z]+ )+[a-z]+.*'",  # Frases em inglês com aspas simples
    '"Now:',  # Específico da screenshot
    '"Week ',  # Week X
    '"Eating"',
    '"Breakfast"',
    '"Lunch"',
    '"Dinner"',
    '"Snack"'
)

$results = @()

Get-ChildItem -Path $libPath -Recurse -Include *.dart |
    Where-Object {
        $exclude = $false
        foreach ($dir in $excludeDirs) {
            if ($_.FullName -like "*\$dir\*") {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } |
    ForEach-Object {
        $file = $_
        $content = Get-Content $file.FullName -Raw

        foreach ($pattern in $patterns) {
            $matches = [regex]::Matches($content, $pattern)
            if ($matches.Count -gt 0) {
                foreach ($match in $matches) {
                    $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
                    $results += [PSCustomObject]@{
                        File = $file.FullName.Replace((Get-Location).Path, ".")
                        Line = $lineNumber
                        Text = $match.Value
                    }
                }
            }
        }
    }

if ($results.Count -eq 0) {
    Write-Host "✅ Nenhuma string hardcoded encontrada!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Encontradas $($results.Count) strings potencialmente hardcoded:" -ForegroundColor Yellow
    $results | Format-Table -AutoSize

    # Exportar para CSV para análise
    $results | Export-Csv -Path "i18n_audit_results.csv" -NoTypeInformation
    Write-Host "`n📄 Resultados exportados para: i18n_audit_results.csv" -ForegroundColor Cyan
}

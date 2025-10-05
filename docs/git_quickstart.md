Git + Backups: Guia Rápido

Checkpoints estáveis
- Criar repositório e primeiro checkpoint:
  - `git init`
  - `git add .`
  - `git commit -m "checkpoint: projeto estável"`
  - `git tag -a stable-1 -m "projeto estável"`

- Novo checkpoint (após ajustes):
  - `git add -A`
  - `git commit -m "checkpoint: passo X"`
  - `git tag -a stable-2 -m "estável pós passo X"`

Branches de trabalho
- Criar e trocar para uma branch de feature: `git switch -c feat/passo-1`
- Voltar para a principal: `git switch -`

Restaurar rapidamente
- Um arquivo a partir do HEAD: `git restore caminho/do/arquivo.dart`
- Um arquivo a partir de um tag: `git restore --source stable-1 -- caminho/do/arquivo.dart`
- Ver histórico de um arquivo (VS Code): aba “Timeline” do arquivo.

Stash (salvar rascunho sem commit)
- Guardar alterações: `git stash -u -m "WIP: descrição"`
- Listar: `git stash list`
- Aplicar e remover da pilha: `git stash pop`

Geração de backups ZIP (somente arquivos rastreados pelo Git)
- Checkpoint com tag + ZIP: `./scripts/git-checkpoint.ps1 -Message "Descrição" -Zip`
- Exportar HEAD em ZIP: `./scripts/backup.ps1`
- Exportar um tag específico: `./scripts/backup.ps1 -Tag stable-2`

Fluxo recomendado (curto)
1) `./scripts/git-checkpoint.ps1 -Message "checkpoint: diário ok" -Zip`
2) `git switch -c feat/passo-1`
3) Fazer uma mudança pequena, testar.
4) `./scripts/git-checkpoint.ps1 -Message "passo 1: botão água" -Zip`

Observações
- Evite manter cópias como `*- Copia.dart` dentro de `lib/` — mova-as para uma pasta fora do repositório.
- Para reduzir o tamanho do ZIP, o script usa `git archive` (somente arquivos versionados).


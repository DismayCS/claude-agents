# Template: versionamento SemVer via release-drafter

CI portátil que versiona o repositório seguindo **SemVer**, a partir da branch
`develop`, usando **labels do Pull Request** para decidir o tipo de bump, e
gera um **draft de release** cuja descrição é montada a partir do corpo de
cada PR (que, no fluxo `ramifica → commeta → concilia → publica`, já contém a
lista de commits padronizados daquele escopo).

## O que cada arquivo faz

- `workflows/release-drafter.yml` — roda a cada push em `develop`. Atualiza
  (ou cria) um **draft de release** com a próxima versão calculada e o
  changelog agregado desde a última release publicada.
- `workflows/require-semver-label.yml` — roda em todo PR aberto/atualizado
  contra `develop`. Falha se o PR não tiver nenhuma label de versionamento —
  isso é o que força a disciplina de sempre rotular o PR antes do merge.
- `release-drafter.yml` — configuração: mapeamento de labels para
  major/minor/patch, categorias do changelog, e o template da nota de release.

## Mapeamento de labels → versão

| Label            | Bump  |
|------------------|-------|
| `major`, `breaking` | major (`X.0.0`) |
| `minor`, `feature`  | minor (`0.X.0`) |
| `patch`, `fix`      | patch (`0.0.X`) |

Sem nenhuma dessas labels, o PR **não pode ser mergeado** (o job
`require-semver-label` falha) — desde que essa branch protection esteja
configurada (ver abaixo).

## Como instalar num projeto novo

1. Copie as pastas/arquivos para o repositório de destino:
   ```
   templates/release-drafter/workflows/release-drafter.yml        → .github/workflows/release-drafter.yml
   templates/release-drafter/workflows/require-semver-label.yml   → .github/workflows/require-semver-label.yml
   templates/release-drafter/release-drafter.yml                  → .github/release-drafter.yml
   ```
2. Crie as labels no repositório (uma vez só):
   ```
   gh label create major    --color B60205 --description "Breaking change (versao major)"
   gh label create breaking --color B60205 --description "Breaking change (versao major)"
   gh label create minor    --color 0E8A16 --description "Nova feature (versao minor)"
   gh label create feature  --color 0E8A16 --description "Nova feature (versao minor)"
   gh label create patch    --color FBCA04 --description "Fix/ajuste (versao patch)"
   gh label create fix      --color FBCA04 --description "Fix/ajuste (versao patch)"
   ```
3. Configure a branch protection da `develop` no GitHub (Settings → Branches)
   para exigir o status check `check-label` (do workflow
   `require-semver-label`) antes de permitir merge.
4. Garanta que o repositório já tenha a branch `develop` enviada ao remoto —
   o `release-drafter` calcula a versão com base nela (`commitish: develop`).

## Uso no dia a dia

Nenhuma ação manual extra é necessária: ao criar o PR (ex: via agente
`publica`), adicione uma label de versionamento antes de mergear. A cada
merge na `develop`, o draft de release é criado/atualizado automaticamente.
Quando quiser publicar a versão, é só abrir o draft no GitHub e clicar em
"Publish release" — isso também cria a tag correspondente.

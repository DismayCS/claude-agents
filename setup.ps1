# Ativa os agentes deste repositório em nivel de usuario no Windows.
# Cria uma Junction (nao precisa de admin) entre ~/.claude/agents e a pasta agents/ deste repo.

$ErrorActionPreference = "Stop"

$repoAgents = Join-Path $PSScriptRoot "agents"
$claudeDir  = Join-Path $env:USERPROFILE ".claude"
$targetDir  = Join-Path $claudeDir "agents"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
}

if (Test-Path $targetDir) {
    $item = Get-Item $targetDir -Force
    if ($item.LinkType) {
        Write-Host "Link existente encontrado em $targetDir, recriando..."
        Remove-Item $targetDir -Force -Recurse
    } else {
        Write-Error "Ja existe uma pasta REAL (nao e link) em $targetDir. Mova/mescle o conteudo manualmente e rode o script de novo."
        exit 1
    }
}

New-Item -ItemType Junction -Path $targetDir -Target $repoAgents | Out-Null
Write-Host "OK: $targetDir -> $repoAgents"

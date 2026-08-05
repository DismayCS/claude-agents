# claude-agents

Repositório pessoal de agentes customizados (subagents) do Claude Code, pensado para ser clonado e ativado em qualquer computador/projeto.

## Estrutura

```
claude-agents/
├── agents/                         # Um arquivo .md por agente (frontmatter + instruções)
│   └── commeta.md
├── templates/
│   └── agent-request-template.md   # Preencher para especificar um novo agente sem ambiguidade
├── setup.ps1                       # Ativa os agentes no Windows
└── setup.sh                        # Ativa os agentes no macOS/Linux/Git Bash
```

Os agentes ficam disponíveis **em nível de usuário**: o Claude Code procura por subagents em `~/.claude/agents/`. Este repositório faz esse diretório apontar (via link/junction) para a pasta `agents/` aqui dentro, então qualquer agente adicionado aqui já fica disponível em todos os projetos daquela máquina.

## Configurar em uma máquina nova

1. Clone este repositório em qualquer lugar (ex: `~/claude-agents`).
2. Rode o script de setup correspondente:
   - **Windows (PowerShell):** `./setup.ps1`
   - **macOS/Linux/Git Bash:** `./setup.sh`
3. Pronto — abra o Claude Code em qualquer projeto e os agentes já estarão disponíveis.

O script cria um link entre `~/.claude/agents` e a pasta `agents/` deste repo (não copia arquivos), então qualquer `git pull` aqui atualiza os agentes automaticamente em todas as máquinas.

## Adicionar um novo agente

1. Copie `templates/agent-request-template.md`, preencha e revise o escopo/gatilho/regras.
2. A partir do template preenchido, crie `agents/<nome-do-agente>.md` com frontmatter (`name`, `description`, `tools`, `model` opcional) seguido das instruções do agente.
3. Faça commit e, se usar em outras máquinas, `git pull` nelas.

## Agentes existentes

- **ramifica** — acionado manualmente no **início** de uma tarefa. Abre uma worktree + branch nova isolada para a tarefa (a partir da base develop/main/master, ou a partir de outra branch/worktree em andamento, se você informar que a tarefa depende dela). Nunca infere dependência sozinho, nunca dá push, nunca cria PR.
- **commeta** — cria commits Git padronizados (`[NOME-COMMIT] - [TIPO]: Descrição`) dentro da worktree, sempre que uma feature/fix/refactor é concluída. Nunca dá push.
- **concilia** — especialista em resolver conflitos reais de merge/rebase (ex: a branch da qual você depende avançou enquanto você trabalhava). Diferencia conflito de texto (resolve) de dependência real de código (aborta e reporta, em vez de forçar uma resolução).
- **publica** — acionado manualmente no **fim** de uma tarefa. Mostra o plano (branch, alvo do PR, título) e, após sua confirmação, faz push, cria o PR como draft via `gh` CLI, remove a worktree local e atualiza a referência remota na pasta principal.

### Fluxo de trabalho (ramifica → commeta → concilia → publica)

Cada tarefa vive na sua própria worktree, isolada desde o início — não existe mais uma branch única do dia misturando várias features (e, com isso, não existe mais cherry-pick nem risco de reconciliar conflitos entre features depois do fato).

1. No início de uma tarefa, você chama o **ramifica**, dizendo do que se trata e (se for o caso) de qual outra branch/tarefa em andamento ela depende. Ele cria a worktree + branch já isolada, a partir da base ou da branch dependente.
2. Você trabalha nessa worktree. O **commeta** vai commitando cada mudança concluída no padrão `[NOME-COMMIT] - [TIPO]: Descrição`.
3. Se a branch da qual você depende avançar enquanto trabalha e um merge/rebase conflitar, o **concilia** resolve conflitos de texto ou identifica uma incompatibilidade real (nesse caso, aborta e reporta para você decidir).
4. Ao terminar, você chama o **publica**. Ele mostra o plano completo (branch, alvo do PR — base ou branch dependente —, título) e, após sua confirmação, faz push, cria o PR como draft, remove a worktree e dá `git fetch` na pasta principal — deixando a branch disponível pra checkout ali, sem mais estar presa a nenhuma pasta.
5. Antes de mergear o PR, adicione uma label de versionamento (`major`/`breaking`, `minor`/`feature`, ou `patch`/`fix`). Ao mergear na `develop`, o CI de versionamento (ver abaixo) atualiza um draft de release com a próxima versão SemVer e a descrição do que foi implementado.

## CI de versionamento (SemVer via labels de PR)

Em `templates/release-drafter/` há um workflow portátil de CI que versiona o repositório em SemVer a partir da `develop`, usando labels do PR pra decidir o bump, e mantém um draft de release atualizado com o changelog. Veja `templates/release-drafter/README.md` para instruções de instalação em qualquer projeto.

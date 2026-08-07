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

- **ramifica** — acionado manualmente no **início** de uma tarefa. Abre uma worktree + branch nova isolada para a tarefa (a partir da base develop/main/master, ou a partir de outra branch/worktree em andamento, se você informar que a tarefa depende dela). Também pode vincular uma **tech-plan** (colada no chat, ou por nome — nesse caso busca no sistema de arquivos e exige sua confirmação de qual arquivo é o certo). Grava tudo isso (dependência, tech-plan, branch de origem) num arquivo de metadata `.claude-task.json` na raiz da worktree, usado depois pelo `publica`. Nunca infere dependência sozinho, nunca dá push, nunca cria PR.
- **commeta** — cria commits Git padronizados (`[NOME-COMMIT] - [TIPO]: Descrição`) dentro da worktree, sempre que uma feature/fix/refactor é concluída. Nunca dá push.
- **concilia** — especialista em resolver conflitos reais de merge/rebase (ex: a branch da qual você depende avançou enquanto você trabalhava). Diferencia conflito de texto (resolve) de dependência real de código (aborta e reporta, em vez de forçar uma resolução).
- **qa** — valida a qualidade do código de uma branch: lint (com autofix de formatação quando seguro), roda os testes existentes, revisa a lógica em busca de bugs reais, e sugere (sem commitar direto) testes para lógica sem cobertura. Pode ser chamado a qualquer momento, e é acionado automaticamente pelo `publica` como gate antes do PR — reprovado bloqueia sempre, sem override.
- **publica** — roda o **qa** primeiro (sem exceção); monta um PR com corpo estruturado (Problemática, Contexto, Resolução, Validações, Validações manuais), assign automático e label de versionamento automática. Se a tarefa **não** tem tech-plan vinculada (no `.claude-task.json` do `ramifica`), é acionado manualmente no fim da tarefa e sempre mostra o plano e pede confirmação antes de agir. Se a tarefa **tem** tech-plan vinculada, é acionado automaticamente ao fim da implementação e age direto (push, PR draft, remoção da worktree) sem parar para confirmar. Em qualquer um dos dois fluxos, ao publicar avisa (via notificação) qualquer outra worktree que dependa dessa branch.
- **daily** — acionado manualmente para gerar um relatório do que foi feito hoje, agregando os commits do `commeta` (por autor) em todas as worktrees do repositório atual, agrupados por `NOME-COMMIT`/`TIPO`. Salva em `~/claude-dailies/<repo>/<data>.md`. Não escreve código, não commita, não dá push.

### Metadata de tarefa (`.claude-task.json`)

O `ramifica` grava, na raiz de cada worktree que cria, um arquivo `.claude-task.json` (nunca commitado) com `nome_commit`, `branch`, `origem`, `depende_de` (e o SHA da dependência no momento da criação) e `tech_plan`. É esse arquivo que permite ao `publica` saber automaticamente se deve rodar no fluxo manual ou automático, e avisar outras worktrees quando a dependência delas for publicada.

### Fluxo de trabalho (ramifica → commeta → concilia → qa → publica)

Cada tarefa vive na sua própria worktree, isolada desde o início — não existe mais uma branch única do dia misturando várias features (e, com isso, não existe mais cherry-pick nem risco de reconciliar conflitos entre features depois do fato).

1. No início de uma tarefa, você chama o **ramifica**, dizendo do que se trata, (se for o caso) de qual outra branch/tarefa em andamento ela depende, e (se for o caso) a tech-plan de origem. Ele cria a worktree + branch já isolada e grava o `.claude-task.json`.
2. Você trabalha nessa worktree. O **commeta** vai commitando cada mudança concluída no padrão `[NOME-COMMIT] - [TIPO]: Descrição`. Em qualquer momento você também pode chamar o **qa** pra validar o que já foi feito, ou o **daily** pra ver o resumo do dia.
3. Se a branch da qual você depende avançar enquanto trabalha e um merge/rebase conflitar, o **concilia** resolve conflitos de texto ou identifica uma incompatibilidade real (nesse caso, aborta e reporta para você decidir).
4. Ao terminar: se a tarefa tinha tech-plan vinculada, o **publica** é chamado automaticamente; senão, você chama ele explicitamente. Ele roda o **qa** como gate — se reprovar, para ali e reporta o motivo (não há mais override; é preciso corrigir e chamar o `publica` de novo). Se aprovar: no fluxo manual, mostra o plano completo e espera sua confirmação antes de agir; no fluxo automático (tech-plan), age direto. Em ambos: faz push, cria o PR como draft (com assign automático), remove a worktree, dá `git fetch` na pasta principal, e notifica (via `PushNotification`) qualquer outra worktree que dependa dessa branch.
5. Antes de mergear o PR, confira a label de versionamento (o `publica` já aplica automaticamente com base no tipo predominante: `major`/`breaking`, `minor`/`feature`, ou `patch`/`fix`). Ao mergear na `develop`, o CI de versionamento (ver abaixo) atualiza um draft de release com a próxima versão SemVer e a descrição do que foi implementado.

## CI de versionamento (SemVer via labels de PR)

Em `templates/release-drafter/` há um workflow portátil de CI que versiona o repositório em SemVer a partir da `develop`, usando labels do PR pra decidir o bump, e mantém um draft de release atualizado com o changelog. Veja `templates/release-drafter/README.md` para instruções de instalação em qualquer projeto.

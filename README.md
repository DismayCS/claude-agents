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

- **commeta** — cria commits Git padronizados (`[NOME-COMMIT] - [TIPO]: Descrição`) sempre que uma feature/fix/refactor é concluída. Nunca dá push.
- **ramifica** — acionado manualmente no fim do dia. Pega os commits da branch de trabalho, agrupa por escopo (`NOME-COMMIT`) e cria uma branch por escopo a partir da base (develop/main/master), via cherry-pick. Nunca dá push nem cria PR. Só apaga a branch de trabalho original depois de verificar que tudo foi replicado corretamente.
- **concilia** — especialista em resolver conflitos de cherry-pick, acionado pelo ramifica. Diferencia conflito de texto (resolve) de dependência real entre features (converte em branch empilhada e reporta, em vez de forçar uma resolução).
- **publica** — acionado manualmente para publicar as branches: detecta branches locais sem upstream, faz push e cria os PRs (draft) via `gh` CLI, respeitando dependências entre branches empilhadas. Sempre mostra o plano e pede confirmação antes de executar.

### Fluxo de trabalho (commeta → ramifica → concilia → publica)

1. Você cria uma branch pessoal de trabalho a partir da develop e implementa várias features/fixes ao longo do dia.
2. O **commeta** vai commitando cada mudança concluída no padrão `[NOME-COMMIT] - [TIPO]: Descrição`.
3. No fim do dia, você chama o **ramifica** explicitamente. Ele separa os commits em uma branch por escopo, a partir da develop.
4. Se algum cherry-pick conflitar, o ramifica delega ao **concilia**, que resolve conflitos de texto ou identifica dependências reais entre features (branches empilhadas).
5. Quando quiser publicar, você chama o **publica** explicitamente. Ele mostra o plano (branches, alvo de cada PR, título) e, após sua confirmação, faz push e cria os PRs como draft no GitHub.

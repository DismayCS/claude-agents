# claude-agents

Repositório pessoal de agentes customizados (subagents) do Claude Code, pensado para ser clonado e ativado em qualquer computador/projeto.

## Estrutura

```
claude-agents/
├── agents/                         # Um arquivo .md por agente (frontmatter + instruções)
│   └── commeta.md
├── viewer/
│   └── agents-viewer.html          # Visualizador local: árvore de relação + histórico real de chamadas
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

- **ramifica** — acionado no **início** de uma tarefa, por dois gatilhos equivalentes: pedido explícito ("abre uma branch pra..."), **ou** o simples envio/colagem/anexo de uma tech-plan (isso sozinho já basta — não precisa pedir pra abrir a tarefa depois). A única exceção é quando fica claro que é só revisão/discussão da tech-plan, não implementação. Abre a worktree + branch nova isolada (a partir da base develop/main/master, ou de outra branch/worktree em andamento, se você informar a dependência), **sempre** no padrão fixo `<nome-do-repo>-worktrees/<nome-da-branch>` — nunca em pasta solta ou local ad-hoc. Grava tudo isso (dependência, tech-plan, branch de origem) num arquivo de metadata `.claude-task.json` na raiz da worktree, usado depois pelo `publica`. Nunca infere dependência sozinho, nunca dá push, nunca cria PR.
- **commeta** — cria commits Git padronizados (`[NOME-COMMIT] - [TIPO]: Descrição`) dentro da worktree, sempre que uma feature/fix/refactor é concluída. Nunca dá push.
- **concilia** — especialista em resolver conflitos reais de merge/rebase (ex: a branch da qual você depende avançou enquanto você trabalhava). Diferencia conflito de texto (resolve) de dependência real de código (aborta e reporta, em vez de forçar uma resolução).
- **qa** — valida a qualidade do código de uma branch: lint (com autofix de formatação quando seguro), roda os testes existentes, revisa a lógica em busca de bugs reais, e sugere (sem commitar direto) testes para lógica sem cobertura. Pode ser chamado a qualquer momento, e é acionado automaticamente pelo `publica` como gate antes do PR — reprovado bloqueia sempre, sem override.
- **publica** — roda o **qa** primeiro (sem exceção); monta um PR com corpo estruturado (Problemática, Contexto, Resolução, Validações, Validações manuais), assign automático e label de versionamento automática. **O PR é sempre criado em draft, sem exceção nenhuma, em nenhum fluxo — nunca é o `publica` quem tira ele do draft, isso é sempre uma ação manual do usuário no GitHub.** Se a tarefa **não** tem tech-plan vinculada (nem no `.claude-task.json` do `ramifica`, nem enviada agora pelo usuário), é acionado manualmente no fim da tarefa e sempre mostra o plano e pede confirmação antes de agir. Se a tarefa **tem** tech-plan vinculada — desde a criação ou informada só agora —, age direto (push, PR draft, remoção da worktree) sem parar para confirmar. Sempre tenta remover a worktree ao final (inclusive se encontrar o PR já merged e a worktree só não tinha sido limpa ainda). Em qualquer um dos fluxos, ao publicar avisa (via notificação) qualquer outra worktree que dependa dessa branch.
- **daily** — gera um relatório do que foi feito hoje, agregando os commits do `commeta` (por autor) em todas as worktrees do repositório atual, agrupados por `NOME-COMMIT`/`TIPO`. Salva em `~/claude-dailies/<repo>/<data>.md`. Acionado sob pedido explícito, e também automaticamente pelo `publica` logo após cada PR publicado (mantendo o snapshot do dia sempre atualizado — é essa a fonte que alimenta a aba Atividade Diária do viewer). Não escreve código, não commita, não dá push.
- **product-owner** — mantém um mapa vivo do projeto em `.github/PRODUCT.md` na raiz do repositório: módulos, features existentes, integração com repositórios irmãos e convenções. Aciona sozinho apenas quando o arquivo ainda não existe (análise completa, primeira vez). Depois disso, só é chamado por outro agente, em um de dois modos: **consulta** (o `ramifica` chama antes de abrir a worktree, só pra checar se a feature já existe — read-only) ou **atualização incremental** (o `publica` chama ao fechar a tarefa, pra registrar o que foi entregue — nunca reprocessa tudo do zero). Nunca escreve código de feature, nunca commita, nunca dá push.

### Metadata de tarefa (`.claude-task.json`)

O `ramifica` grava, na raiz de cada worktree que cria, um arquivo `.claude-task.json` (nunca commitado) com `nome_commit`, `branch`, `origem`, `depende_de` (e o SHA da dependência no momento da criação) e `tech_plan`. É esse arquivo que permite ao `publica` saber automaticamente se deve rodar no fluxo manual ou automático, e avisar outras worktrees quando a dependência delas for publicada.

### Log de comunicação entre agentes (`~/claude-agent-comm/<repo>/agent-comm.jsonl`)

É observabilidade de execução, não parâmetro de projeto — por isso vive numa pasta pessoal fora do repositório, no mesmo espírito do `daily` (`~/claude-dailies/<repo>/...`), em vez de dentro de `.claude/` do projeto. Sempre que um agente delega para outro (`ramifica`→`product-owner`, `publica`→`qa`, `publica`→`product-owner`, `publica`→`daily`) ou dispara uma notificação de dependência, quem chama registra uma linha JSON em `~/claude-agent-comm/<nome-do-repo>/agent-comm.jsonl`. Cada linha tem `ts`, `from`, `to`, `action` (`consulta`/`delegacao`/`resultado`/`notificacao`), `detail` e `worktree`. É esse arquivo que alimenta o histórico real de comunicação entre agentes (quem chamou quem, quando, e por quê) — a convenção completa está descrita no agente `product-owner`.

### Visualizador (`viewer/agents-viewer.html`)

Arquivo HTML autocontido (sem dependências externas) — abra direto no navegador com duplo clique. Duas abas:

- **Mapa de Comunicação** — árvore de relação entre os agentes (fluxo de trabalho + delegações reais). Botão **"Carregar agent-comm.jsonl"** abre o log de um repositório específico e mostra, ao clicar em cada agente, o histórico real de chamadas — contagem por delegação e lista cronológica de eventos.
- **Atividade Diária** — títulos de feature/PR por dia, com os commits de cada uma listados abaixo, a partir dos relatórios do agente `daily` (`~/claude-dailies/<repo>/<data>.md`). Em Chrome/Edge, o botão **"Conectar pasta de dailies"** usa a File System Access API: você concede acesso à pasta uma vez, a permissão fica salva (IndexedDB), e a partir daí a aba relê sozinha a cada 30s e sempre que você volta pra ela — sem escolher arquivo de novo. Em navegadores sem suporte a essa API, cai automaticamente no carregamento manual (múltiplos `.md` por vez).

Em ambos os casos, o carregamento é sempre local ao navegador — nada é enviado pra fora, e nenhum arquivo é lido sem uma ação explícita do usuário (segurança do próprio navegador, não dá pra contornar isso).

**Conexão automática de verdade**: abrir o `.html` direto (`file://`) funciona, mas o Chrome não persiste a permissão de pasta de forma confiável nessa origem — pode pedir pra reconectar a cada sessão nova do navegador. Rode `viewer/iniciar.ps1` (sobe um servidor local em `http://localhost:8743` via `python -m http.server` e já abre o navegador) — nessa origem, a permissão concedida uma vez fica salva de verdade, e da próxima vez que você rodar o script a aba Atividade Diária já abre conectada, sem precisar clicar em nada.

### Fluxo de trabalho (ramifica → commeta → concilia → qa → publica → product-owner)

Cada tarefa vive na sua própria worktree, isolada desde o início — não existe mais uma branch única do dia misturando várias features (e, com isso, não existe mais cherry-pick nem risco de reconciliar conflitos entre features depois do fato).

1. No início de uma tarefa, você chama o **ramifica** dizendo do que se trata (e, se for o caso, de qual outra branch/tarefa em andamento ela depende) — ou simplesmente envia/cola a tech-plan, que já é gatilho suficiente por si só. Ele consulta o **product-owner** (se `.github/PRODUCT.md` já existir) pra avisar se algo parecido já existe, cria a worktree + branch já isolada (sempre em `<repo>-worktrees/<branch>`) e grava o `.claude-task.json`.
2. Você trabalha nessa worktree. O **commeta** vai commitando cada mudança concluída no padrão `[NOME-COMMIT] - [TIPO]: Descrição`. Em qualquer momento você também pode chamar o **qa** pra validar o que já foi feito, ou o **daily** pra ver o resumo do dia.
3. Se a branch da qual você depende avançar enquanto trabalha e um merge/rebase conflitar, o **concilia** resolve conflitos de texto ou identifica uma incompatibilidade real (nesse caso, aborta e reporta para você decidir).
4. Ao terminar: se a tarefa tinha tech-plan vinculada — desde a criação ou enviada só agora —, o **publica** age automaticamente; senão, você chama ele explicitamente. Ele roda o **qa** como gate — se reprovar, para ali e reporta o motivo (não há mais override; é preciso corrigir e chamar o `publica` de novo). Se aprovar: no fluxo manual, mostra o plano completo e espera sua confirmação antes de agir; no fluxo automático, age direto. Em ambos: faz push, cria o PR como draft (com assign automático), remove a worktree (mesmo se descobrir que o PR já foi merged antes), dá `git fetch` na pasta principal, notifica (via `PushNotification`) qualquer outra worktree que dependa dessa branch, atualiza o **product-owner** (modo incremental) com o que foi entregue, e aciona o **daily** (a partir da pasta principal) pra manter o snapshot do dia atualizado — sempre, em todo fluxo.
5. Antes de mergear o PR, confira a label de versionamento (o `publica` já aplica automaticamente com base no tipo predominante: `major`/`breaking`, `minor`/`feature`, ou `patch`/`fix`). Ao mergear na `develop`, o CI de versionamento (ver abaixo) atualiza um draft de release com a próxima versão SemVer e a descrição do que foi implementado.

## CI de versionamento (SemVer via labels de PR)

Em `templates/release-drafter/` há um workflow portátil de CI que versiona o repositório em SemVer a partir da `develop`, usando labels do PR pra decidir o bump, e mantém um draft de release atualizado com o changelog. Veja `templates/release-drafter/README.md` para instruções de instalação em qualquer projeto.

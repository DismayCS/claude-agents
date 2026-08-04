# Template de especificação de agente

Preencha os campos abaixo e me envie. Quanto mais completo, menos suposições eu preciso fazer.

## 1. Identificação
- **Nome do agente** (kebab-case, ex: `code-reviewer`, `db-migrator`):
- **Objetivo em 1 frase** (o que ele resolve):

## 2. Quando deve ser acionado
- **Gatilho automático** — descreva as situações/frases do usuário que devem fazer o Claude Code escolher esse agente proaticamente (isso vira o campo `description`, que é o que o modelo usa para decidir quando delegar):
- **Uso explícito** — o usuário vai chamá-lo por nome (`/nome-do-agente` ou "use o agente X")? Sim/Não:

## 3. Escopo e comportamento
- **O que ele DEVE fazer** (passos, ordem, regras específicas):
- **O que ele NÃO deve fazer** (limites, ações proibidas):
- **Entrada esperada** (o que o agente recebe: um path, uma descrição de tarefa, uma lista de arquivos, etc.):
- **Saída esperada** (formato do resultado: texto livre, JSON estruturado, lista de findings, arquivo modificado, etc.):

## 4. Ferramentas necessárias
Marque as que o agente vai usar (pode listar outras não citadas):
- [ ] Leitura de arquivos (Read/Glob/Grep)
- [ ] Edição/escrita de arquivos (Edit/Write)
- [ ] Execução de comandos (Bash/PowerShell)
- [ ] Busca na web (WebSearch/WebFetch)
- [ ] Acesso a outros agentes (delegar sub-tarefas)
- [ ] Nenhuma restrição — todas as ferramentas (`*`)
- [ ] Outras (especifique):

## 5. Modelo (opcional)
- Precisa de um modelo específico (ex: mais rápido/barato para tarefas mecânicas, ou mais capaz para raciocínio complexo)? Ou herda o modelo da sessão principal?

## 6. Contexto adicional
- Esse agente depende de algum projeto, stack, convenção ou ferramenta externa específica (ex: sempre roda em repos Python, sempre usa determinado MCP server)?
- Exemplos de uso (1-2 cenários reais de quando o agente seria chamado e o que deveria acontecer):

## 7. Escopo de disponibilidade
- Esse agente é **genérico** (útil em qualquer projeto) ou **específico de um projeto/stack**? Se específico, qual?

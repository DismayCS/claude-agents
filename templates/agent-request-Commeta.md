# Template de especificação de agente

Preencha os campos abaixo e me envie. Quanto mais completo, menos suposições eu preciso fazer.

## 1. Identificação
- Nome: **Commeta** 
- Objetivo: **Fazer commit padronizado de acordo com feature/fix/refactor** 

## 2. Quando deve ser acionado
- **Gatilho automático** — descreva as situações/frases do usuário que devem fazer o Claude Code escolher esse agente proaticamente (isso vira o campo `description`, que é o que o modelo usa para decidir quando delegar): Ele deve ser acionado sempre que a feature/fix/refactor for acabado, toda e qualquer decisão involvendo add e commit do github deve ser delegada para ele.
- **Uso explícito** — o usuário vai chamá-lo por nome (`/nome-do-agente` ou "use o agente X")? Sim/Não: Não

## 3. Escopo e comportamento
- **O que ele DEVE fazer** (passos, ordem, regras específicas): Ele deve sempre gerar mensagens pradronizadas de acordo com a feature, exemplo:" {NOME-COMMIT} - {TIPO(FEATURE/FIX/REFACTOR)}: {DESCRIÇÃO BREVE}", caso seja necessario dividir o commit em duas partes porem a feature ainda é a mesma voce deve usar o mesmo NOME-COMMIT, o NOME-COMMIT so deve ser mudado quando a feature/fix/refactor, for um escopo diferente.
- **O que ele NÃO deve fazer** (limites, ações proibidas): 
 - Nunca fazer um titulo diferente do especificado.
 - Não usar caracteres especiais
 - Nunca colocar diversos escopos diferentes em um unico commit
 - Nunca fazer push da branch
 - Nunca usar NOME-COMMIT diferente para o mesmo escopo.
- **Entrada esperada** (o que o agente recebe: um path, uma descrição de tarefa, uma lista de arquivos, etc.): O agente não ira receber uma entrada espeficica.
- **Saída esperada** (formato do resultado: texto livre, JSON estruturado, lista de findings, arquivo modificado, etc.): Uma pequena lista de commits criados no projeto até o momento.

## 4. Ferramentas necessárias
Marque as que o agente vai usar (pode listar outras não citadas):
- [X] Leitura de arquivos (Read/Glob/Grep)
- [X] Edição/escrita de arquivos (Edit/Write)
- [X] Execução de comandos (Bash/PowerShell)
- [ ] Busca na web (WebSearch/WebFetch)
- [ ] Acesso a outros agentes (delegar sub-tarefas)
- [ ] Nenhuma restrição — todas as ferramentas (`*`)
- [ ] Outras (especifique):

## 5. Modelo (opcional)
- Precisa de um modelo específico (ex: mais rápido/barato para tarefas mecânicas, ou mais capaz para raciocínio complexo)? Ou herda o modelo da sessão principal? pode ser um modelo simples, talvez um sonnet.

## 6. Contexto adicional
- Esse agente depende de algum projeto, stack, convenção ou ferramenta externa específica (ex: sempre roda em repos Python, sempre usa determinado MCP server)? Não precisa de nada muito especifico, ele precisa ser capaz de executar comandos do git apenas.
- Exemplos de uso (1-2 cenários reais de quando o agente seria chamado e o que deveria acontecer):
1º Cenario: Ao terminar uma feature de uma legenda uma tela especifica, ele deve ser acionado automaticamente e deve criar um commit seguindo os padroes ja especificados exemplo "[Legenda-na-tela] - [FEATURE]: adicionado legenda na tela!".
2º Cenario: Ao terminar a implementação de multiplas features o usuario pode chamar ou avisar para fazer os commits, ele deve criar os commits para todas as features implementadas se for o mesmo escopo deve ser o mesmo commit, exemplo: "[Emissão-de-etiquetas] - [FEATURE]: Adicionado campo observacao!", "[Emissão-de-etiquetas] - [FEATURE]: Adicionado adicionado codigo de partnumber!",
[Emissão-de-etiquetas] - [FIX]: Ajustado campo de gravacao!",
"[Tela-de-registro] - [REFACTOR]: Melhora de desempenho!".

## 7. Escopo de disponibilidade
- Esse agente é **genérico** (útil em qualquer projeto) ou **específico de um projeto/stack**? Se específico, qual? Genérico.

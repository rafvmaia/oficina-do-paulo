# Prompt orquestrador: App "Oficina do Paulo"

> Abra uma sessão nova do Claude Code nesta pasta (`oficina`) e cole tudo abaixo da linha.

---

Você é o **orquestrador** da construção do app Android **Oficina do Paulo**, feito em **React Native (Expo)**. Você **não escreve o código do app**: você coordena agentes especialistas, um por fase, que desenvolvem e testam (como engenheiros de QA) cada parte, e só avança quando a fase anterior está comprovadamente pronta.

## Arquivos

- `agentes/CONTEXTO.md`: especificação completa do produto, da stack, das cores e do banco (Supabase).
- `agentes/QA.md`: protocolo Dev + QA obrigatório e critério de pronto de toda fase.
- `agentes/fases/01…10-*.md`: escopo e plano de testes de cada fase.

Leia os três antes de começar.

## Como executar

1. **Uma fase por vez, em ordem (01 → 10).** Elas dependem umas das outras e trabalham no mesmo código; por isso rodam em sequência, sem paralelismo.
2. Para cada fase, lance **um subagente** (ferramenta Agent, tipo `general-purpose`, em primeiro plano) com este prompt:

   > Você é o agente da **Fase NN** do app Oficina do Paulo, atuando como desenvolvedor e engenheiro de QA ao mesmo tempo. Leia `agentes/CONTEXTO.md`, `agentes/QA.md`, `agentes/fases/NN-*.md` e `STATUS.md` (se existir). Execute a fase inteira seguindo o protocolo de QA, sem pedir confirmação: só termine com o PR mergeado e o CI verde na `main`, ou com um bloqueio registrado. Responda com o relatório final da fase descrito em `agentes/QA.md`.

3. **Verifique o gate você mesmo** antes de seguir (não confie só no relatório):
   - `gh pr list --state merged --search "fase-NN"`: o PR existe e foi mergeado
   - `gh run list --branch main --limit 3`: o último run está verde
   - `docs/qa/fase-NN.md` existe, com resultados preenchidos
   - `STATUS.md` atualizado
4. Se o gate falhar, relance o agente da mesma fase dizendo exatamente o que faltou (no máximo 2 relançamentos). Se ainda falhar, registre em `STATUS.md` → **BLOQUEIOS** e avance só se a próxima fase não depender do item bloqueado.
5. Entre as fases, mande ao usuário **uma única linha** de progresso (ex.: "✅ Fase 03 concluída: 42 testes, CI verde. Iniciando a Fase 04: Login."). Não peça revisão nem aprovação: o usuário quer que o trabalho siga sozinho.

## Únicas interações com o usuário

- **Supabase**: o usuário só tem conta no supabase.com e roda `npx supabase login` uma vez. Depois disso, **o orquestrador** faz o resto pelo CLI/Management API, sem expor segredos no chat:
  1. criar o projeto `oficina-do-paulo` (região `sa-east-1`, plano Free) com senha do banco gerada por `openssl rand`;
  2. obter URL, anon key e project ref;
  3. gravar os secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_PROJECT_REF`, `SUPABASE_DB_PASSWORD` e `SUPABASE_ACCESS_TOKEN` com `gh secret set` (valores passados por stdin, nunca impressos);
  4. desativar o cadastro público (`disable_signup`) na configuração de Auth.
  As fases 01 a 09 **não dependem** disso (os testes usam um Supabase local no CI).
- **Login do Paulo**: o usuário cria o usuário (e-mail e senha) no painel *Authentication → Users*. Passe o link direto no fim.
- **Antes da Fase 10**: confira com `gh secret list`. Se faltar algo, avise o usuário com a lista exata e aguarde.
- **Bloqueio** que nenhum agente consegue resolver: explique em 3 linhas e peça só o necessário.

## Entrega final

Quando a Fase 10 terminar, responda ao usuário com:
1. **Link de download do APK** (`.../releases/latest`) e o passo a passo de instalação no celular.
2. Resumo: fases concluídas, total de testes, bugs encontrados e corrigidos pelo QA.
3. Onde está o keystore (`~/Documents/OficinaDoPaulo-keystore/`) e o aviso de fazer backup dele.
4. Pendências ou riscos conhecidos (do `STATUS.md`).

# Fase 04 — Login e sessão

**Papel:** engenheiro Android + QA.

## Escopo

1. Tela de **login** (e-mail e senha) com a marca da oficina: logo, "Oficina do Paulo", campos grandes, botão "Entrar", mostrar/ocultar senha. **Sem** tela de cadastro.
2. Mensagens em pt-BR: credenciais inválidas, sem internet, servidor não configurado (placeholders), erro genérico.
3. Sessão persistida (supabase-kt): app abre direto nas abas se já logado; refresh de token automático.
4. Ao logar: dispara o primeiro sync completo com indicador "Baixando seus dados…".
5. **Configurações**: e-mail da conta, estado do sync com botão "Sincronizar agora", versão do app, botão "Sair" com confirmação (avisar se houver pendências não enviadas).
6. Indicador de sync na top bar (da fase 03) ligado à UI.

## Plano de testes

- ViewModel: campos vazios, e-mail inválido, sucesso, erro de credencial, sem rede, servidor não configurado (auth falso injetado).
- Robolectric: validação visual dos erros; botão desabilitado enquanto carrega (sem duplo envio); navegação para as abas após sucesso; tema escuro.
- Logout com pendências mostra aviso; sem pendências sai direto para o login.

## Critério de pronto

CI verde; fluxo login → abas → sair coberto por teste de tela.

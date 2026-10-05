# Fase 04 — Login e sessão

**Papel:** engenheiro React Native + QA.

## Escopo

1. Tela de **login** (e-mail e senha) com a marca da oficina: logo, "Oficina do Paulo", campos grandes, botão "Entrar", mostrar/ocultar senha. **Sem** tela de cadastro.
2. Mensagens em pt-BR: credenciais inválidas, sem internet, servidor não configurado, erro genérico.
3. Sessão persistida: app abre direto nas abas se já logado (proteção de rotas no Expo Router); refresh de token automático.
4. Ao logar: dispara o primeiro sync completo com indicador "Baixando seus dados…".
5. **Configurações**: e-mail da conta, estado do sync com botão "Sincronizar agora", versão do app, botão "Sair" com confirmação (avisar se houver pendências não enviadas; ao sair, limpar o banco local).
6. Indicador de sync no cabeçalho (da fase 03) ligado à UI.

## Plano de testes

- Lógica de login (hook/serviço) com auth falso: campos vazios, e-mail inválido, sucesso, credencial errada, sem rede, servidor não configurado.
- RNTL: erros exibidos; botão desabilitado enquanto carrega (sem duplo envio); redireciona às abas após sucesso; tema escuro.
- Logout com pendências mostra aviso; sem pendências sai direto e limpa dados locais.
- Rota protegida: sem sessão sempre cai no login.

## Critério de pronto

Local e CI verdes; fluxo login → abas → sair coberto por teste de tela.

# Fase 10 — QA final independente e release v1.0.0

**Papel:** engenheiro de QA sênior **que não escreveu o código**. Seu trabalho é tentar quebrar o app antes do Paulo. Você pode corrigir bugs, sempre com teste de regressão.

## Escopo

1. **Revisão geral**: ler todo o código e os `docs/qa/fase-*.md`; procurar lacunas de teste, regras divergentes entre TypeScript e SQL, dinheiro com decimais, textos em inglês, telas sem estado vazio/erro, `any` e `@ts-ignore`.
2. **Testes de integração (RNTL)** cobrindo a jornada real:
   - Login → cadastrar cliente com veículo → criar serviço → pagamento parcial → cobrar via WhatsApp (verificar URL do `Linking`) → marcar como pago → recibo → conferir Início e A Receber → excluir pagamento → desfazer → sair.
   - Mesma jornada no tema escuro.
   - Jornada offline com sync posterior (FakeRemote).
3. **E2E no emulador (Maestro)**: fluxos em `.maestro/` para (a) cadastrar cliente + serviço + marcar como pago e conferir o chip PAGO em detalhe, lista e A Receber; (b) pagamento parcial. Workflow `e2e.yml` (`workflow_dispatch` e PR para `main`) usando `reactivecircus/android-emulator-runner` em ubuntu, instalando o APK do build. Use um modo de teste que dispense o Supabase real (ex.: variável `EXPO_PUBLIC_MODO_DEMO=1` que pula o login e usa só o banco local) — ele **não** pode estar ativo no APK de release.
4. **Revisão de segurança**: RLS em todas as tabelas, nenhum segredo no histórico do git (`git log -p | grep -iE "service_role|password|BEGIN PRIVATE"`), `service_role` nunca usado no app, `.env` fora do repo, modo demo desligado no release.
5. **Release**:
   - Verificar `gh secret list`: se faltarem `SUPABASE_URL` ou `SUPABASE_ANON_KEY`, **pare e avise o orquestrador** com a lista do que falta (não publique release sem o servidor configurado).
   - `README.md` em pt-BR: o que o app faz, como rodar os testes, como gerar nova versão (`git tag v1.0.1 && git push --tags`), secrets necessários, onde está o keystore e por que não pode perdê-lo, como criar/alterar o usuário no Supabase, como **instalar o APK no celular** (permitir "instalar apps desconhecidos") e o link fixo `https://github.com/rafvmaia/oficina-do-paulo/releases/latest`.
   - Criar tag `v1.0.0`, acompanhar `release.yml` até o fim e confirmar o APK anexado ao Release.
6. Gerar `docs/qa/relatorio-final.md`: total de testes, cobertura, bugs encontrados/corrigidos, riscos conhecidos.

## Critério de pronto

CI e E2E verdes na `main`, Release v1.0.0 publicado com APK assinado, README completo, relatório final escrito.

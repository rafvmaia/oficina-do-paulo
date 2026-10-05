# Fase 10 — QA final independente e release v1.0.0

**Papel:** engenheiro de QA sênior **que não escreveu o código**. Seu trabalho é tentar quebrar o app antes do Paulo. Você pode corrigir bugs, sempre com teste de regressão.

## Escopo

1. **Revisão geral**: ler todo o código e os `docs/qa/fase-*.md`; procurar lacunas de teste, regras de negócio divergentes entre Kotlin e SQL, uso de `Double` para dinheiro, textos em inglês, telas sem estado vazio/erro.
2. **Testes de regressão ponta a ponta** (Robolectric), cobrindo a jornada real:
   - Login → cadastrar cliente com veículo → criar serviço → pagamento parcial → cobrar via WhatsApp (verificar intent) → marcar como pago → recibo → conferir Início e A Receber → excluir pagamento → desfazer → sair.
   - Mesma jornada no tema escuro e com fonte do sistema em 1.3×.
   - Jornada offline com sync posterior (FakeRemote).
3. **Revisão de segurança**: RLS em todas as tabelas, nenhum segredo no repo (`git log -p | grep` por chaves), `service_role` nunca usado no app, `android:allowBackup` pensado, `FileProvider` restrito.
4. **Release**:
   - Verificar `gh secret list`: se faltarem `SUPABASE_*`, **pare e avise o orquestrador** com a lista do que o usuário precisa configurar (não faça release sem o servidor configurado).
   - Atualizar `README.md` em pt-BR: o que o app faz, como gerar nova versão (`git tag v1.0.1 && git push --tags`), secrets necessários, onde está o keystore e por que não pode perdê-lo, como criar/alterar o usuário no Supabase, como **instalar o APK no celular** (permitir "instalar apps desconhecidos"), e o link fixo `https://github.com/<usuario>/oficina-do-paulo/releases/latest`.
   - Criar tag `v1.0.0`, acompanhar `release.yml` até o fim e confirmar o APK anexado ao Release.
5. Gerar `docs/qa/relatorio-final.md`: total de testes, cobertura, bugs encontrados/corrigidos, riscos conhecidos.

## Critério de pronto

CI verde na `main`, Release v1.0.0 publicado com APK assinado, README completo, relatório final escrito.

# Fase 02 — Banco de dados Supabase (schema, segurança e testes)

**Papel:** engenheiro de banco de dados + QA.

## Escopo

1. Estrutura `supabase/` (use `npx supabase init`; não precisa instalar nada globalmente).
2. **Migration** `supabase/migrations/<timestamp>_schema_inicial.sql`:
   - Tabelas `clientes`, `veiculos`, `servicos`, `pagamentos` conforme CONTEXTO.md, `id uuid primary key`, `owner_id uuid not null default auth.uid()`, `created_at`, `updated_at`, `deleted_at`.
   - Valores em `bigint` (centavos); `check (valor_centavos > 0)`, `check (total_centavos >= 0)`, `check` dos enums (ou tipos enum).
   - FKs entre as tabelas; índices em `owner_id`, `updated_at`, FKs e `clientes(nome)`.
   - Trigger que atualiza `updated_at` em todo update **somente se o cliente não enviou um valor mais novo** (o app envia o próprio `updated_at` para o desempate de sync).
   - Trigger que calcula `total_centavos = mao_de_obra_centavos + pecas_centavos`.
   - Trigger de exclusão lógica em cascata: `deleted_at` em cliente → propaga para veículos, serviços e pagamentos; em serviço → pagamentos.
   - **RLS ativado** em todas as tabelas com políticas select/insert/update para `owner_id = auth.uid()`; **sem política de delete** (só exclusão lógica).
   - View `servicos_resumo` (`security_invoker = true`) com `total_pago_centavos`, `falta_centavos`, `status_pagamento` seguindo exatamente a regra do CONTEXTO.md.
3. **CI** `supabase.yml`: em push/PR que altere `supabase/**`: `supabase/setup-cli`, `supabase db start`, `supabase test db`. **Não** faça deploy pelo CI.
4. **Deploy no projeto real é feito pelo orquestrador, do Mac** (o CLI já está logado): `npx supabase link --project-ref yzxhtjgohhcympttvxri` e `npx supabase db push`. Você NÃO roda esses comandos; apenas garanta que `supabase/config.toml` tenha `[auth] enable_signup = false` e que as migrations funcionem num banco limpo.
5. `keepalive.yml`: cron a cada 3 dias fazendo um `select` simples via REST em `clientes` usando os secrets `SUPABASE_URL` e `SUPABASE_ANON_KEY` (a resposta pode ser vazia/401 por RLS — o que importa é a requisição chegar ao projeto); pula se os secrets não existirem.

## Plano de testes (pgTAP em `supabase/tests/`)

- Estrutura: tabelas, colunas, tipos, FKs e RLS habilitado existem.
- **Isolamento RLS**: usuário A não lê, não altera e não insere com `owner_id` do usuário B; anônimo não lê nada.
- Delete físico negado para usuário autenticado.
- `total_centavos` calculado corretamente; constraints rejeitam valor 0/negativo e enum inválido.
- `servicos_resumo`: PENDENTE (sem pagamentos), PARCIAL, PAGO exato, PAGO com sobra (falta = 0), total 0 → PAGO, pagamento excluído logicamente é ignorado.
- Cascata lógica: excluir cliente marca veículos, serviços e pagamentos.
- `updated_at`: update com valor mais antigo não sobrescreve um mais novo.

## Critério de pronto

`supabase test db` verde no CI, migration idempotente em banco limpo, documentação do schema em `docs/banco.md` (diagrama mermaid das tabelas).

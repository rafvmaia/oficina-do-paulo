# Fase 03 — Banco local (SQLite + Drizzle) e sincronização

**Papel:** engenheiro React Native (dados) + QA.

## Escopo

1. **Domínio** (`src/domain`): tipos `Cliente`, `Veiculo`, `Servico`, `Pagamento`, enums, e a função pura `calcularResumoPagamento(totalCentavos, pagamentos) => { totalPago, falta, status }` — mesma regra do CONTEXTO.md e da view SQL da fase 02.
2. **Schema Drizzle** (`src/db/schema.ts`) espelhando o Supabase + `pendente_sync`; migrations do `drizzle-kit` versionadas e aplicadas na abertura do app (`useMigrations`).
3. **Repositórios** (`src/db/repos/*`), recebendo o `db` por parâmetro:
   - consultas filtrando `deleted_at is null`; busca por nome/telefone/placa; agregados de resumo por serviço, por cliente e total geral em aberto.
   - toda escrita: gera UUID, `updated_at = agora`, `pendente_sync = 1`, e notifica o agendador de sync.
   - exclusão = lógica, em cascata.
4. **Reatividade**: hooks (`useClientes`, `useServico`, `useResumoCliente`…) que atualizam a tela quando os dados mudam (ex.: `useLiveQuery` do Drizzle com change listener do expo-sqlite, ou um event bus próprio). Documente a escolha em `docs/arquitetura.md`.
5. **Supabase client** (`src/lib/supabase.ts`) com `AsyncStorage`, `autoRefreshToken`, e detecção de "não configurado".
6. **Sync** (`src/sync`): interface `RemoteDataSource` + implementação Supabase; `sincronizar()` conforme CONTEXTO.md; `ultimo_sync` persistido; disparo por login, `AppState` ativo, NetInfo online, debounce pós-escrita e intervalo de 5 min. Expor estado observável: `sincronizado | sincronizando | offline(pendentes) | erro(msg)`.
7. Teste em memória: configure Jest para os repositórios rodarem com **better-sqlite3** e o mesmo schema/migrations.

## Plano de testes

- `calcularResumoPagamento`: tabela de casos (sem pagamento, parcial, exato, a mais, total 0, pagamentos excluídos, valores grandes).
- Repositórios (better-sqlite3 em memória): CRUD, filtro de excluídos, busca por nome/telefone/placa, agregados por cliente e total em aberto, cascata de exclusão, escrita marca `pendente_sync`.
- Sync com `FakeRemoteDataSource`:
  - envia pendentes e limpa a flag
  - baixa novos e atualizados
  - conflito: local mais novo vence / remoto mais novo vence
  - exclusão remota chega ao local
  - falha de rede mantém pendentes e estado `offline`
  - sync repetido é idempotente (não duplica)
  - duas chamadas simultâneas de `sincronizar()` não rodam em paralelo
- Tabela de casos da regra de status documentada em `docs/qa/fase-03.md` e **idêntica** à usada no pgTAP da fase 02 (se divergir, corrija e registre).

## Critério de pronto

Local e CI verdes; cobertura de `src/domain`, `src/db` e `src/sync` ≥ 80% (relatório do Jest no CI); `docs/arquitetura.md` escrito.

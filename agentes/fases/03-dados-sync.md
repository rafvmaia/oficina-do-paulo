# Fase 03 — Camada de dados local (Room) e sincronização

**Papel:** engenheiro Android (dados) + QA.

## Escopo

1. **Domínio** (`domain/`): modelos `Cliente`, `Veiculo`, `Servico`, `Pagamento`, enums, e a função pura `calcularResumoPagamento(totalCentavos, pagamentos): ResumoPagamento(totalPago, falta, status)` — mesma regra do CONTEXTO.md e da view SQL.
2. **Room**: entities espelhando o Supabase + `pendente_sync`; DAOs com `Flow`; consultas já filtrando `deleted_at is null`; consultas agregadas para resumo por serviço, por cliente e total geral em aberto. Exportar schema (`room.schemaLocation`) e versionar.
3. **Repositórios**: única porta de acesso para a UI. Toda escrita: gera UUID, seta `updated_at = agora`, `pendente_sync = true`, e agenda sync. Exclusão = lógica, em cascata.
4. **Supabase client** (`supabase-kt`): `SUPABASE_URL`/`SUPABASE_ANON_KEY` via `BuildConfig` (placeholders se ausentes — build não falha).
5. **Sync** (`SyncWorker` com WorkManager) conforme CONTEXTO.md: push de pendentes (upsert), pull incremental por `updated_at`, desempate por `updated_at` mais recente, guarda `ultimo_sync` em DataStore. Expor `StateFlow<EstadoSync>` (Sincronizado, Sincronizando, Offline(pendentes), Erro(msg)).
6. Interface `RemoteDataSource` para o sync poder ser testado com uma implementação fake.
7. `AppContainer` montando tudo.

## Plano de testes

- `calcularResumoPagamento`: tabela de casos (sem pagamento, parcial, exato, a mais, total 0, pagamentos excluídos, valores grandes sem overflow).
- DAOs (Room in-memory + Robolectric): CRUD, filtros de excluídos, busca por nome/telefone/placa, agregados por cliente e total em aberto.
- Repositórios: escrita marca `pendente_sync`; exclusão de cliente cascateia.
- Sync com `FakeRemoteDataSource`:
  - envia pendentes e limpa a flag
  - baixa novos e atualizados
  - conflito: local mais novo vence / remoto mais novo vence
  - exclusão remota chega ao local
  - falha de rede mantém pendentes e estado `Offline`
  - sync repetido é idempotente (não duplica)
- Teste de que a regra de status do Kotlin e a da view SQL têm **os mesmos casos** (documentar a tabela em `docs/qa/fase-03.md` e referenciar no teste pgTAP).

## Critério de pronto

CI verde, cobertura dos pacotes `domain` e `data` ≥ 80% (gerar relatório Kover ou JaCoCo no CI), schema Room exportado.

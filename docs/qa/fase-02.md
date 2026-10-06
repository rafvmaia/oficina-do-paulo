# QA — Fase 02: Banco Supabase (schema, segurança e testes)

## Plano de testes (escrito antes da implementação)

Todos os casos são testes pgTAP em `supabase/tests/`, executados no CI por `supabase test db` sobre um Supabase local limpo (`supabase db start` aplica as migrations do zero).

| #   | Área              | Caso                                                                                                                 | Tipo                 | Arquivo                       |
| --- | ----------------- | -------------------------------------------------------------------------------------------------------------------- | -------------------- | ----------------------------- |
| E1  | Estrutura         | as 4 tabelas e a view `servicos_resumo` existem                                                                      | estrutura            | `00_estrutura.test.sql`       |
| E2  | Estrutura         | colunas obrigatórias e tipos (`uuid`, `bigint` para centavos, `timestamptz`, `date`, `text`)                         | estrutura            | `00_estrutura.test.sql`       |
| E3  | Estrutura         | `owner_id` com padrão `auth.uid()`; `NOT NULL` nos campos obrigatórios                                               | estrutura            | `00_estrutura.test.sql`       |
| E4  | Estrutura         | FKs: veículos→clientes, serviços→clientes/veículos, pagamentos→serviços                                              | estrutura            | `00_estrutura.test.sql`       |
| E5  | Estrutura         | índices em `owner_id`+`updated_at`, FKs e `clientes(nome)`                                                           | estrutura            | `00_estrutura.test.sql`       |
| E6  | Estrutura         | RLS habilitado nas 4 tabelas; políticas só de select/insert/update; nenhuma de delete                                | estrutura            | `00_estrutura.test.sql`       |
| E7  | Estrutura         | view `servicos_resumo` com `security_invoker = true`                                                                 | estrutura            | `00_estrutura.test.sql`       |
| R1  | RLS               | usuário A vê só os próprios registros em todas as tabelas e na view                                                  | segurança            | `01_rls.test.sql`             |
| R2  | RLS               | A não altera registros de B (update afeta 0 linhas e o dado de B fica intacto)                                       | segurança            | `01_rls.test.sql`             |
| R3  | RLS               | A não insere com `owner_id` de B (erro de RLS)                                                                       | segurança            | `01_rls.test.sql`             |
| R4  | RLS               | A não transfere um registro próprio para B (update de `owner_id` negado)                                             | segurança            | `01_rls.test.sql`             |
| R5  | RLS               | A não pendura veículo/serviço/pagamento em registro de B (FK composta com `owner_id`)                                | segurança / borda    | `01_rls.test.sql`             |
| R6  | RLS               | anônimo não lê nada (tabelas e view) e não insere                                                                    | segurança            | `01_rls.test.sql`             |
| R7  | RLS               | delete físico negado ao usuário autenticado (e `truncate`), registro continua existindo                              | segurança            | `01_rls.test.sql`             |
| R8  | RLS               | insert sem `owner_id` grava `auth.uid()`                                                                             | caminho feliz        | `01_rls.test.sql`             |
| V1  | Regras            | `total_centavos = mao_de_obra_centavos + pecas_centavos` no insert e no update (ignora total enviado pelo app)       | caminho feliz        | `02_regras.test.sql`          |
| V2  | Regras            | centavos nulos viram 0; total 0 permitido                                                                            | borda                | `02_regras.test.sql`          |
| V3  | Regras            | pagamento com valor 0 ou negativo é rejeitado; mão de obra/peças negativas rejeitadas                                | erro                 | `02_regras.test.sql`          |
| V4  | Regras            | `status_servico` e `forma` inválidos rejeitados; todos os valores válidos aceitos                                    | erro / caminho feliz | `02_regras.test.sql`          |
| V5  | Regras            | nome/telefone/placa/descrição vazios ou nulos rejeitados; ano fora de 1900–2100 e km negativo rejeitados             | erro                 | `02_regras.test.sql`          |
| U1  | `updated_at`      | update sem `updated_at` novo → servidor avança `updated_at` (sempre crescente)                                       | caminho feliz        | `02_regras.test.sql`          |
| U2  | `updated_at`      | update com `updated_at` mais novo → valor do app é mantido                                                           | sync                 | `02_regras.test.sql`          |
| U3  | `updated_at`      | update com `updated_at` mais antigo → não sobrescreve o mais novo (nem o dado: escrita obsoleta é descartada)        | sync / borda         | `02_regras.test.sql`          |
| U4  | `updated_at`      | upsert (`insert … on conflict do update`) obsoleto também é descartado                                               | sync / borda         | `02_regras.test.sql`          |
| S1  | `servicos_resumo` | sem pagamentos → PENDENTE, falta = total                                                                             | caminho feliz        | `03_servicos_resumo.test.sql` |
| S2  | `servicos_resumo` | pagamento parcial → PARCIAL, falta correta                                                                           | caminho feliz        | `03_servicos_resumo.test.sql` |
| S3  | `servicos_resumo` | soma exata → PAGO, falta 0                                                                                           | borda                | `03_servicos_resumo.test.sql` |
| S4  | `servicos_resumo` | pagamento com sobra → PAGO, falta 0 (nunca negativa)                                                                 | borda                | `03_servicos_resumo.test.sql` |
| S5  | `servicos_resumo` | total 0 → PAGO                                                                                                       | borda                | `03_servicos_resumo.test.sql` |
| S6  | `servicos_resumo` | pagamento excluído logicamente é ignorado                                                                            | borda                | `03_servicos_resumo.test.sql` |
| S7  | `servicos_resumo` | vários pagamentos somados; valores grandes (bigint) sem perda                                                        | borda                | `03_servicos_resumo.test.sql` |
| C1  | Cascata           | excluir cliente marca veículos, serviços e pagamentos com o mesmo `deleted_at`                                       | caminho feliz        | `04_cascata.test.sql`         |
| C2  | Cascata           | excluir serviço marca só os pagamentos dele                                                                          | caminho feliz        | `04_cascata.test.sql`         |
| C3  | Cascata           | registros de outro cliente não são afetados; itens já excluídos mantêm o `deleted_at` original                       | borda                | `04_cascata.test.sql`         |
| C4  | Cascata           | filhos atingidos pela cascata têm `updated_at` avançado (para o sync baixar)                                         | sync                 | `04_cascata.test.sql`         |
| CI1 | CI                | `supabase.yml`: `supabase db start` aplica as migrations num banco limpo, `supabase test db` verde                   | CI                   | GitHub Actions                |
| CI2 | CI                | migration idempotente: reaplicar o arquivo no mesmo banco não dá erro e os testes continuam verdes                   | CI                   | GitHub Actions                |
| CI3 | CI                | `keepalive.yml`: requisição REST a `clientes`; pula se os secrets não existirem                                      | CI                   | GitHub Actions (manual)       |
| CI4 | CI                | `ci.yml` não roda o build do APK em PR que só mexe em `supabase/**`/docs; continua rodando na `main` e em PRs do app | CI                   | GitHub Actions                |

Offline: não se aplica ao banco remoto (o app lê sempre do SQLite — fase 03). Os casos de sync (U1–U4, C4) garantem o desempate por `updated_at` quando o app reenviar pendências feitas offline.

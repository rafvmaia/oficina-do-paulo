# STATUS — Oficina do Paulo

| Fase                                | Situação     | PR  | QA                                       |
| ----------------------------------- | ------------ | --- | ---------------------------------------- |
| 01 — Fundação, tema e CI/CD         | em andamento | —   | [docs/qa/fase-01.md](docs/qa/fase-01.md) |
| 02 — Banco Supabase                 | pendente     | —   | —                                        |
| 03 — Dados locais e sync            | pendente     | —   | —                                        |
| 04 — Login                          | pendente     | —   | —                                        |
| 05 — Clientes e veículos            | pendente     | —   | —                                        |
| 06 — Serviços                       | pendente     | —   | —                                        |
| 07 — Pagamentos                     | pendente     | —   | —                                        |
| 08 — A receber e cobrança           | pendente     | —   | —                                        |
| 09 — Início, recibo e configurações | pendente     | —   | —                                        |
| 10 — QA final e release             | pendente     | —   | —                                        |

## Notas da fase 01

- Stack fixada: Expo SDK 57 (React Native 0.86, React 19.2), Expo Router 57, React Native Paper 5.15, Jest 29 + jest-expo 57, @testing-library/react-native 14 (render/fireEvent assíncronos — sempre `await`).
- Release: tag `v*` ou `workflow_dispatch` (input `versao`) → `OficinaDoPaulo-v{versão}.apk`. Variável de repositório `ASSINATURA_SHA256` guarda o SHA-256 público do certificado de produção.
- Secrets `SUPABASE_URL`/`SUPABASE_ANON_KEY` são injetados só no passo do Gradle (nunca nos testes).

## Pendências

- Nenhuma.

## Bugs encontrados e corrigidos

- Fase 01: teste de navegação dependia de variáveis do Supabase do ambiente (corrigido com mock + teste novo).
- Fase 01: extração do SHA-256 da saída do `apksigner` no release (corrigido).

## BLOQUEIOS

- Nenhum.

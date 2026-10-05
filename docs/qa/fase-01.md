# QA — Fase 01: Fundação, tema e CI/CD

## Plano de testes (escrito antes da implementação)

| #   | Área                  | Caso                                                                                                                    | Tipo                                 | Automação                              |
| --- | --------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | -------------------------------------- |
| D1  | `formatarCentavos`    | 0 → `R$ 0,00`                                                                                                           | caminho feliz / borda                | Jest                                   |
| D2  | `formatarCentavos`    | 5 → `R$ 0,05`                                                                                                           | borda                                | Jest                                   |
| D3  | `formatarCentavos`    | 100 → `R$ 1,00`                                                                                                         | caminho feliz                        | Jest                                   |
| D4  | `formatarCentavos`    | 123456 → `R$ 1.234,56`                                                                                                  | caminho feliz                        | Jest                                   |
| D5  | `formatarCentavos`    | 100000000 → `R$ 1.000.000,00`                                                                                           | borda (valor alto)                   | Jest                                   |
| D6  | `formatarCentavos`    | -1550 → `-R$ 15,50`                                                                                                     | borda (negativo)                     | Jest                                   |
| D7  | `formatarCentavos`    | valor não inteiro / `NaN` / `Infinity` → erro                                                                           | erro                                 | Jest                                   |
| D8  | `parseValor`          | `"12,50"` → 1250                                                                                                        | caminho feliz                        | Jest                                   |
| D9  | `parseValor`          | `"1.234,56"` → 123456                                                                                                   | caminho feliz                        | Jest                                   |
| D10 | `parseValor`          | `"R$ 10"` → 1000                                                                                                        | caminho feliz                        | Jest                                   |
| D11 | `parseValor`          | `""` e só espaços → `null`                                                                                              | erro                                 | Jest                                   |
| D12 | `parseValor`          | `"abc"` → `null`                                                                                                        | erro                                 | Jest                                   |
| D13 | `parseValor`          | `"12,555"` (3 casas) → `null`                                                                                           | borda                                | Jest                                   |
| D14 | `parseValor`          | `"12,5"`, `"0,99"`, `"1234"`, `"12.50"`, `"1.000"`, `"R$1.234,5"`                                                       | bordas de formato                    | Jest                                   |
| D15 | `parseValor`          | negativo, separador de milhar inválido (`"1.23,00"`), dois separadores decimais → `null`                                | erro                                 | Jest                                   |
| D16 | `parseValor`          | ida e volta: `parseValor(formatarCentavos(n)) === n`                                                                    | propriedade                          | Jest                                   |
| T1  | Tema                  | cores claro/escuro iguais à tabela do CONTEXTO.md                                                                       | unidade                              | Jest                                   |
| T2  | Tema                  | `useColorScheme` escuro → tema escuro; claro/nulo → claro                                                               | unidade                              | Jest                                   |
| C1  | `StatusPagamentoChip` | PAGO/PARCIAL/PENDENTE: texto, ícone (✓ / ◐ / !) e cor corretos — tema claro                                             | RNTL                                 | Jest                                   |
| C2  | `StatusPagamentoChip` | idem no tema escuro                                                                                                     | RNTL                                 | Jest                                   |
| C3  | `StatusPagamentoChip` | `testID="chip-status-pagamento"` e `accessibilityLabel`                                                                 | RNTL                                 | Jest                                   |
| C4  | `BotaoPrincipal`      | altura ≥ 56dp, `onPress` chamado, desabilitado não dispara, carregando                                                  | RNTL                                 | Jest                                   |
| C5  | `CampoTexto`          | rótulo, digitação dispara `onChangeText`, mensagem de erro visível só quando há erro                                    | RNTL                                 | Jest                                   |
| C6  | `EstadoVazio`         | ícone e texto; ação opcional                                                                                            | RNTL                                 | Jest                                   |
| C7  | `DialogoConfirmacao`  | visível mostra título/mensagem; Confirmar e Cancelar chamam callbacks; invisível não renderiza                          | RNTL                                 | Jest                                   |
| N1  | Navegação             | layout renderiza as 4 abas (Início, Clientes, A Receber, Serviços)                                                      | RNTL (`expo-router/testing-library`) | Jest                                   |
| N2  | Navegação             | tocar em cada aba mostra o título/estado vazio correto                                                                  | RNTL                                 | Jest                                   |
| N3  | Navegação             | botão Configurações no cabeçalho abre a tela de Configurações                                                           | RNTL                                 | Jest                                   |
| N4  | Navegação             | telas renderizam no tema escuro                                                                                         | RNTL                                 | Jest                                   |
| P1  | Plugin assinatura     | com as 4 variáveis → `signingConfigs.release` com `storeType "pkcs12"` e `buildTypes.release` usando-o                  | unidade                              | Jest                                   |
| P2  | Plugin assinatura     | sem variáveis → gradle inalterado (release cai no debug)                                                                | unidade                              | Jest                                   |
| P3  | Plugin assinatura     | idempotente (aplicar 2× não duplica)                                                                                    | unidade                              | Jest                                   |
| A1  | `app.config.ts`       | nome, slug, pacote; `APP_VERSION`/`APP_VERSION_CODE` com padrões; versionCode inválido cai no padrão                    | unidade                              | Jest                                   |
| A2  | Config Supabase       | variáveis ausentes → `supabaseConfigurado = false` (build não falha)                                                    | unidade                              | Jest                                   |
| CI1 | CI                    | `ci.yml`: typecheck, lint, test:ci verdes                                                                               | CI                                   | GitHub Actions                         |
| CI2 | CI                    | `android-build` gera APK como artifact                                                                                  | CI                                   | GitHub Actions                         |
| CI3 | Release               | `release.yml` via `workflow_dispatch` gera APK assinado com o keystore de produção (SHA-256 igual ao `certificado.pem`) | CI + verificação manual              | GitHub Actions + `apksigner`/`openssl` |

Offline: esta fase não tem dados nem rede; não se aplica (justificado).

## Resultado

(preenchido ao final da fase)

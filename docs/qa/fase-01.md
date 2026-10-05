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

- **108 testes Jest** em 11 suítes, todos verdes (local e CI). Cobertura: ~93% das instruções.
- Todos os casos do plano automatizados (D1–D16, T1–T2, C1–C7, N1–N4, P1–P3, A1–A2), exceto CI1–CI3, verificados nos runs abaixo.
- Verificações locais extras: `npx expo-doctor` (21/21), `npx expo config` e `npx expo prebuild --platform android --no-install` (sem Gradle) para conferir o `build.gradle` gerado com o plugin de assinatura.
- CI1/CI2 (PR #2): run [37354026765](https://github.com/rafvmaia/oficina-do-paulo/actions/runs/37354026765) — qualidade + `android-build` verdes, APK publicado como artifact `oficina-do-paulo-apk`.
- CI3 (release por tag `v0.0.1-teste.3`): run [37354026360](https://github.com/rafvmaia/oficina-do-paulo/actions/runs/37354026360) — `apksigner` mostrou `CN=Oficina do Paulo`, SHA-256 `21bb6201beec95c482fbeeea37af61fd32937c61902c26038c0a7d2566e0797c`, idêntico ao `openssl x509 -fingerprint -sha256` do `certificado.pem` local. O SHA esperado ficou fixado na variável de repositório `ASSINATURA_SHA256` e o release falha se não bater.

### Bugs encontrados pelo QA durante a fase

1. O teste de navegação dependia das variáveis `EXPO_PUBLIC_SUPABASE_*` do ambiente; quando os secrets do Supabase foram criados, o release falhou. Corrigido: o teste mocka a configuração (com um caso novo para "Configurado") e os secrets só chegam ao passo do Gradle.
2. O passo de conferência da assinatura extraía o SHA-256 errado da saída do `apksigner` (`awk -F': '` pegava o rótulo). Corrigido com `awk '{print $NF}'`.

### Observações

- O RNTL v14 tem `render` assíncrono e o `renderRouter` do `expo-router/testing-library` ainda é síncrono: o teste aguarda a Promise retornada e usa o `getPathname()` anexado a ela.
- Offline: não se aplica nesta fase (sem dados nem rede).

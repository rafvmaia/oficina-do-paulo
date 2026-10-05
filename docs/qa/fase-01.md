# QA — Fase 01: Fundação, tema e CI/CD

## Plano de testes

### Unitários (JVM) — `DinheiroTest`

| ID | Caso | Esperado |
|---|---|---|
| U01 | `formatarCentavos(0)` | `R$ 0,00` |
| U02 | `formatarCentavos(5)` | `R$ 0,05` |
| U03 | `formatarCentavos(100)` | `R$ 1,00` |
| U04 | `formatarCentavos(123456)` | `R$ 1.234,56` |
| U05 | `formatarCentavos(100000000)` | `R$ 1.000.000,00` |
| U06 | `formatarCentavos(-1050)` (negativo) | `-R$ 10,50` |
| U07 | `formatarCentavos(Long.MIN_VALUE)` / `Long.MAX_VALUE` (borda) | não estoura, formata corretamente |
| U08 | `parseValor("12,50")` | `1250` |
| U09 | `parseValor("1.234,56")` | `123456` |
| U10 | `parseValor("R$ 10")` | `1000` |
| U11 | `parseValor("")` e só espaços | `null` |
| U12 | `parseValor("abc")` | `null` |
| U13 | `parseValor("12,555")` (3 casas decimais) | `null` |
| U14 | `parseValor("12,5")`, `parseValor("0,05")`, `parseValor("1.000")`, `parseValor("10.50")` | `1250`, `5`, `100000`, `1050` |
| U15 | `parseValor("-10")`, `"1.23,00"`, `"12,"`, `",50"`, número gigante (overflow) | `null` |
| U16 | Ida e volta: `parseValor(formatarCentavos(x)) == x` para vários x ≥ 0 | igual |

### Tela (Robolectric + Compose UI Test)

| ID | Caso | Esperado |
|---|---|---|
| T01 | App abre (`MainActivity`) | abertura "Oficina do Paulo" e depois barra inferior com 4 abas visíveis |
| T02 | Navegar pelas 4 abas | título da top bar: Início, Clientes, A Receber, Serviços |
| T03 | Cada aba mostra seu estado vazio real | texto de estado vazio específico da aba (nada de "em construção") |
| T04 | Ícone de Configurações na top bar | abre a tela Configurações; voltar retorna à aba anterior |
| T05 | `StatusPagamentoChip` — PAGO / PARCIAL / PENDENTE, tema claro | texto + ícone corretos + cor do CONTEXTO.md |
| T06 | `StatusPagamentoChip` — 3 status, tema escuro | texto + ícone corretos + cor do tema escuro |
| T07 | Navegação em tema escuro | app renderiza e navega no modo escuro |
| T08 | Tela de abertura (splash) | mostra "Oficina do Paulo" e some após o tempo |
| T09 | Componentes base: `BotaoPrincipal` ≥ 56dp e clicável; `CampoTexto` mostra erro; `EstadoVazio` mostra texto; `DialogoConfirmacao` confirma/cancela | comportamento esperado |
| T10 | Toque mínimo: itens da barra inferior e botão de Configurações ≥ 48dp | ok |

### CI/CD

| ID | Caso | Esperado |
|---|---|---|
| C01 | `ci.yml` em PR: `assembleDebug`, `testDebugUnitTest`, `lintDebug` | verde; APK debug e relatórios como artifacts |
| C02 | Build sem secrets `SUPABASE_*` | build não falha (placeholders) |
| C03 | `release.yml` por tag `v*` de teste | APK `OficinaDoPaulo-v{versionName}.apk` assinado (`apksigner verify` no job) e anexado a um GitHub Release; release de teste apagado depois |
| C04 | `release.yml` por `workflow_dispatch` | gera APK assinado (verificado com `apksigner`) |
| C05 | Wrapper do Gradle validado (checksum oficial) | ok |

### Itens não automatizáveis (justificativa)

- Offline / Room / sync: não há dados nesta fase.
- Rotação: não há campos de digitação em telas desta fase; o `CampoTexto` usa estado elevado (o chamador guarda com `rememberSaveable`).
- Pixel-perfect do ícone adaptive: conferido por revisão do vetor; validado em build (`aapt`/lint).

## Resultado

_Preenchido ao final da fase._

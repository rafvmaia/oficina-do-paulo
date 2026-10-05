# Contexto compartilhado — App "Oficina do Paulo"

Todo agente deve ler este arquivo inteiro antes de começar. Ele é a fonte da verdade do produto.
Se algo aqui conflitar com o arquivo da fase, o arquivo da fase vence apenas no escopo daquela fase.

## Produto

App Android nativo para a oficina mecânica **Oficina do Paulo** controlar **clientes, veículos, serviços e pagamentos**.
O requisito mais importante: **saber, de forma impossível de errar, se cada serviço foi pago**.
Toda a interface em **português do Brasil**.

## Restrições do ambiente (IMPORTANTE)

- O Mac do desenvolvedor (MacBook Air M1, 8 GB) **não tem Java nem Android SDK** e **não vamos instalar**.
- **Nunca rode Gradle localmente.** Todo build, teste e lint roda no **GitHub Actions**.
- Ciclo de trabalho: editar → commit em branch → push → `gh run watch` → ler logs de falha (`gh run view --log-failed`) → corrigir → repetir.
- Ferramentas disponíveis localmente: `git`, `gh` (já autenticado), `node`/`npx`, `openssl`, `curl`.
- Antes de fixar versões de bibliotecas (AGP, Kotlin, Compose BOM, Room, supabase-kt, Ktor, Robolectric), **consulte a documentação atual** (MCP context7 ou web). Incompatibilidade de versões é a causa nº 1 de CI vermelho.
- Gradle wrapper: como não há Java local, obtenha os arquivos oficiais do wrapper (ex.: `gradle-wrapper.jar` da tag da versão em `github.com/gradle/gradle`) ou gere o wrapper num job do CI e faça commit. O CI deve usar `./gradlew`.

## Stack

- Kotlin + Jetpack Compose + Material 3, Navigation Compose
- MVVM com `StateFlow`; DI manual com um `AppContainer`
- **Room** como banco local (o app lê SEMPRE do Room → funciona sem internet)
- **Supabase** (Postgres + Auth) como banco na nuvem, via biblioteca `supabase-kt` (módulos auth + postgrest) com Ktor
- **WorkManager** para sincronização
- `minSdk 26`; `compileSdk`/`targetSdk` na versão estável mais recente
- Gradle Kotlin DSL + `libs.versions.toml`
- Pacote: `br.com.oficinadopaulo`
- Testes: JUnit4, kotlinx-coroutines-test, Turbine, **Robolectric + Compose UI Test** (testes de tela rodam na JVM, sem emulador), Room in-memory. Banco Supabase testado com **pgTAP** via `supabase test db` no CI.

## Identidade visual

| Papel | Claro | Escuro |
|---|---|---|
| Primária (laranja ferramenta) | `#E8630A` | `#FF7A1F` |
| Primária pressionada | `#B84D05` | `#E8630A` |
| Top bar / secundária (grafite) | `#1F2A36` | `#1F2A36` |
| Fundo | `#F4F5F7` | `#121820` |
| Superfície (cards) | `#FFFFFF` | `#1F2A36` |
| Texto principal / secundário | `#1A1A1A` / `#5F6B7A` | `#ECEFF3` / `#A9B4C2` |
| **PAGO** | `#2E7D32` | `#66BB6A` |
| **PARCIAL** | `#F9A825` | `#FFCA28` |
| **PENDENTE** | `#C62828` | `#EF5350` |

- Status SEMPRE com cor **+ ícone + texto** (✓ PAGO / ◐ PARCIAL / ! PENDENTE).
- Área de toque mínima 48dp; botões de ação principais 56dp de altura.
- Ícone: chave inglesa + engrenagem laranja sobre grafite (adaptive icon vetorial). Splash com "Oficina do Paulo".

## Modelo de dados

Todas as tabelas (Supabase e Room) têm: `id` (UUID gerado no app), `owner_id` (uuid do usuário Supabase), `created_at`, `updated_at`, `deleted_at` (exclusão lógica — nada é apagado fisicamente, para a sincronização funcionar).

- **clientes**: nome*, telefone*, documento (CPF/CNPJ), endereco, observacoes
- **veiculos**: cliente_id*, placa*, marca, modelo, ano, cor, km
- **servicos**: cliente_id*, veiculo_id, descricao*, pecas (texto), mao_de_obra_centavos, pecas_centavos, total_centavos (= mão de obra + peças), data_entrada*, data_conclusao, status_servico (`ORCAMENTO`, `EM_ANDAMENTO`, `CONCLUIDO`, `ENTREGUE`), observacoes
- **pagamentos**: servico_id*, valor_centavos* (> 0), data*, forma (`DINHEIRO`, `PIX`, `DEBITO`, `CREDITO`, `TRANSFERENCIA`, `OUTRO`), observacao

Dinheiro SEMPRE em **centavos (Long/bigint)**. Exibição: `R$ 1.234,56`.

**Status de pagamento é derivado, nunca gravado à mão** (pagamentos com `deleted_at` são ignorados):
- `PENDENTE`: soma = 0
- `PARCIAL`: 0 < soma < total
- `PAGO`: soma ≥ total (e total > 0); serviço com total 0 conta como `PAGO`
- `falta_centavos = max(total − soma, 0)`

Exclusão de cliente → exclusão lógica em cascata de veículos, serviços e pagamentos.

## Sincronização

- O app lê e escreve sempre no Room. Cada escrita marca o registro como `pendente_sync = true`.
- O worker de sync: (1) **envia** pendentes por upsert; (2) **baixa** tudo com `updated_at > ultimo_sync` (inclusive excluídos logicamente); (3) conflito = **vence o `updated_at` mais recente**.
- Dispara: ao abrir o app, após cada alteração (com debounce) e periodicamente (15 min) com rede disponível.
- Indicador discreto na top bar: sincronizado / sincronizando / offline com N pendências.

## Autenticação

- Uma conta por oficina (e-mail/senha). Todos os aparelhos do Paulo entram com a mesma conta.
- Sem tela de cadastro; o usuário é criado no painel do Supabase e o cadastro público fica desativado.
- RLS em todas as tabelas: `owner_id = auth.uid()`.

## Configuração (sem segredos no código)

- `SUPABASE_URL` e `SUPABASE_ANON_KEY` entram via `BuildConfig`, lidos de variáveis de ambiente / GitHub Secrets. Se ausentes, o build usa placeholders e o app mostra "Servidor não configurado" no login (o build NÃO pode falhar por isso).
- Keystore de assinatura via Secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`.
- Supabase deploy via Secrets: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, `SUPABASE_DB_PASSWORD`.

## Estrutura do repositório

```
app/                      código Android
supabase/migrations/      SQL versionado
supabase/tests/           testes pgTAP
.github/workflows/        ci.yml, release.yml, supabase.yml, keepalive.yml
docs/qa/fase-NN.md        plano e resultado de QA de cada fase
STATUS.md                 progresso geral (atualizado por cada fase)
README.md
```

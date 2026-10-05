# Contexto compartilhado — App "Oficina do Paulo"

Todo agente deve ler este arquivo inteiro antes de começar. Ele é a fonte da verdade do produto.
Se algo aqui conflitar com o arquivo da fase, o arquivo da fase vence apenas no escopo daquela fase.

## Produto

App Android (feito em **React Native**) para a oficina mecânica **Oficina do Paulo** controlar **clientes, veículos, serviços e pagamentos**.
O requisito mais importante: **saber, de forma impossível de errar, se cada serviço foi pago**.
Toda a interface em **português do Brasil**.

## Ambiente e forma de trabalho (IMPORTANTE)

- Mac do desenvolvedor: MacBook Air M1, 8 GB. **Tem** `node`/`npx`, `git`, `gh` (autenticado como `rafvmaia`), `openssl`. **Não tem** Java nem Android SDK e **não vamos instalar**.
- **Rode localmente** (rápido, use à vontade): `npm install`, `npx tsc --noEmit`, `npm run lint`, `npm test` (Jest). Esse é o ciclo principal de QA.
- **Nunca rode Gradle / `expo run:android` localmente.** O APK é gerado só no **GitHub Actions**.
- Repositório: `https://github.com/rafvmaia/oficina-do-paulo` (público, já existe, branch `main`).
- Ciclo: implementar → testar local → commit na branch da fase → push → `gh run watch` → corrigir → PR → merge.
- Antes de fixar versões (Expo SDK, React Native, Paper, Drizzle, supabase-js, Jest), **consulte a documentação atual** (MCP context7 via ToolSearch, ou web). Use `npx expo install <pacote>` para pacotes nativos, para casar as versões com o SDK.
- **Não precisa de conta Expo/EAS.** O build é local no CI: `npx expo prebuild --platform android` + Gradle.

## Stack

- **Expo** (SDK estável mais recente) + **TypeScript strict**
- **Expo Router** (abas + pilhas)
- **React Native Paper** (Material 3) com tema próprio; ícones `@expo/vector-icons` (MaterialCommunityIcons)
- Banco local: **expo-sqlite + Drizzle ORM** (migrations do drizzle-kit versionadas). O app lê SEMPRE do SQLite local → funciona sem internet.
  - Repositórios recebem a instância do banco por parâmetro, para os testes usarem **better-sqlite3 em memória** com o mesmo schema Drizzle.
- Nuvem: **Supabase** (Postgres + Auth) via `@supabase/supabase-js`, sessão em `AsyncStorage`, `react-native-url-polyfill`.
- Rede: `@react-native-community/netinfo`; ciclo de vida: `AppState`.
- Formulários: `react-hook-form` + `zod`.
- PDF: `expo-print`; compartilhar: `expo-sharing`; arquivos: `expo-file-system`.
- Testes: **Jest (preset `jest-expo`) + @testing-library/react-native**; banco Supabase testado com **pgTAP** via `supabase test db` no CI; E2E com **Maestro** em emulador no CI (fase 10).
- Qualidade: ESLint + Prettier; `tsc --noEmit` sem erros.
- Identificador Android: `br.com.oficinadopaulo`.

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

- Tema segue o modo do sistema (claro/escuro).
- Status SEMPRE com cor **+ ícone + texto** (✓ PAGO / ◐ PARCIAL / ! PENDENTE).
- Área de toque mínima 48dp; botões de ação principais 56dp de altura.
- Ícone: chave inglesa + engrenagem laranja sobre grafite (gerar PNG 1024×1024 a partir de um SVG feito no repo; adaptive icon com foreground + cor de fundo). Splash com "Oficina do Paulo" (`expo-splash-screen`).

## Modelo de dados

Todas as tabelas (Supabase e SQLite) têm: `id` (UUID gerado no app — `expo-crypto` `randomUUID`), `owner_id`, `created_at`, `updated_at`, `deleted_at` (exclusão lógica — nada é apagado fisicamente, para a sincronização funcionar). No SQLite, também `pendente_sync`.

- **clientes**: nome*, telefone*, documento (CPF/CNPJ), endereco, observacoes
- **veiculos**: cliente_id*, placa*, marca, modelo, ano, cor, km
- **servicos**: cliente_id*, veiculo_id, descricao*, pecas (texto), mao_de_obra_centavos, pecas_centavos, total_centavos (= mão de obra + peças), data_entrada*, data_conclusao, status_servico (`ORCAMENTO`, `EM_ANDAMENTO`, `CONCLUIDO`, `ENTREGUE`), observacoes
- **pagamentos**: servico_id*, valor_centavos* (> 0), data*, forma (`DINHEIRO`, `PIX`, `DEBITO`, `CREDITO`, `TRANSFERENCIA`, `OUTRO`), observacao

Dinheiro SEMPRE em **centavos inteiros** (`number` inteiro no TS, `integer`/`bigint` no banco). Nunca somar reais com casas decimais. Exibição: `R$ 1.234,56`. Datas no fuso `America/Sao_Paulo`.

**Status de pagamento é derivado, nunca gravado à mão** (pagamentos com `deleted_at` são ignorados):
- `PENDENTE`: soma = 0 (e total > 0)
- `PARCIAL`: 0 < soma < total
- `PAGO`: soma ≥ total; serviço com total 0 conta como `PAGO`
- `falta_centavos = max(total − soma, 0)`

Exclusão de cliente → exclusão lógica em cascata de veículos, serviços e pagamentos.

## Sincronização

- O app lê e escreve sempre no SQLite. Cada escrita marca `pendente_sync = 1` e atualiza `updated_at`.
- Motor de sync: (1) **envia** pendentes por upsert; (2) **baixa** tudo com `updated_at > ultimo_sync` (inclusive excluídos logicamente); (3) conflito = **vence o `updated_at` mais recente**.
- Dispara: após login, ao voltar o app para o primeiro plano, ao voltar a rede, após cada alteração (debounce ~2 s) e a cada 5 min com o app aberto.
- Indicador discreto no cabeçalho: sincronizado / sincronizando / offline com N pendências / erro.

## Autenticação

- Uma conta por oficina (e-mail/senha). Todos os aparelhos do Paulo entram com a mesma conta.
- Sem tela de cadastro; cadastro público desativado no Supabase.
- RLS em todas as tabelas: `owner_id = auth.uid()`.

## Configuração (sem segredos no código)

- `EXPO_PUBLIC_SUPABASE_URL` e `EXPO_PUBLIC_SUPABASE_ANON_KEY` via variáveis de ambiente (no CI, vindas dos Secrets `SUPABASE_URL` e `SUPABASE_ANON_KEY`). Localmente, `.env` (no `.gitignore`) com `.env.example` commitado. Se ausentes, o app mostra "Servidor não configurado" no login — o build NÃO pode falhar por isso.
- Assinatura do APK — **já existe, NÃO gerar outra**: keystore PKCS12 em `~/Documents/OficinaDoPaulo-keystore/` e Secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` já cadastrados no repo.
- Supabase: projeto `oficina-do-paulo`, ref `yzxhtjgohhcympttvxri`, região sa-east-1. Secrets no GitHub: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_PROJECT_REF` (já existem). As migrations são aplicadas no projeto real **pelo orquestrador, a partir do Mac** (`supabase link` + `supabase db push`); o CI só testa em Supabase local. Nenhum token de conta ou senha do banco vai para o GitHub.

## Estrutura do repositório

```
app/                      rotas (Expo Router)
src/components/           componentes de UI reutilizáveis
src/domain/               regras puras (dinheiro, status de pagamento, validações)
src/db/                   schema Drizzle, migrations, repositórios
src/sync/                 motor de sincronização
src/lib/                  supabase client, formatação, utilitários
src/theme/                cores e tema Paper
__tests__/ ou *.test.ts(x) testes Jest
plugins/                  config plugins Expo (ex.: assinatura)
supabase/migrations/      SQL versionado
supabase/tests/           testes pgTAP
.maestro/                 fluxos E2E
.github/workflows/        ci.yml, release.yml, supabase.yml, keepalive.yml, e2e.yml
docs/qa/fase-NN.md        plano e resultado de QA de cada fase
STATUS.md                 progresso geral
```

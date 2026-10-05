# Fase 01 — Fundação, tema e CI/CD

**Papel:** engenheiro React Native + DevOps + QA.

## Já existe (não refazer)

- Repositório público `rafvmaia/oficina-do-paulo`, branch `main` com os arquivos de especificação (`agentes/`, `PROMPT-APP-OFICINA.md`).
- Keystore PKCS12 em `~/Documents/OficinaDoPaulo-keystore/` (leia o `LEIA-ME.txt` só para saber o alias; nunca imprima senhas) e os 4 secrets de assinatura já cadastrados. **Não gere outro keystore.**
- Pode haver um `.gitignore`/`README.md` de uma tentativa anterior em Kotlin: substitua pelo conteúdo correto de Expo.

## Escopo

1. **Projeto Expo** com TypeScript strict na raiz do repo (template com Expo Router; mantenha `agentes/` e `PROMPT-APP-OFICINA.md` intactos). Nome "Oficina do Paulo", `slug` `oficina-do-paulo`, `android.package` `br.com.oficinadopaulo`. Configuração em `app.config.ts` (lê variáveis de ambiente; `version` vem de `APP_VERSION`, `android.versionCode` de `APP_VERSION_CODE`, com padrões).
2. Scripts no `package.json`: `typecheck`, `lint`, `format`, `test`, `test:ci`. ESLint + Prettier configurados. `.gitignore` de Expo (inclui `android/`, `ios/`, `.env`, `*.p12`, `*.jks`).
3. **Tema** (`src/theme`): cores claro/escuro do CONTEXTO.md em um tema React Native Paper MD3; segue o modo do sistema. Ícone adaptive e splash.
4. **Componentes base** (`src/components`), cada um com teste:
   - `StatusPagamentoChip({ status })` — cor + ícone + texto, `testID="chip-status-pagamento"`
   - `src/domain/dinheiro.ts`: `formatarCentavos(n): string` e `parseValor(texto): number | null`
   - `BotaoPrincipal` (56dp), `CampoTexto` com mensagem de erro, `EstadoVazio({ icone, texto })`, `DialogoConfirmacao`
5. **Navegação**: abas inferiores **Início, Clientes, A Receber, Serviços** + botão de Configurações no cabeçalho (cabeçalho grafite). Telas com estado vazio real (nada de "em construção").
6. **Assinatura**: config plugin em `plugins/withAndroidSigning.js` que, no `prebuild`, adiciona um `signingConfig` release lendo `ANDROID_KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` do ambiente, com `storeType "pkcs12"`. Sem essas variáveis, o release cai na assinatura debug (o build não falha).
7. **CI/CD** em `.github/workflows/`:
   - `ci.yml` (push e PR): Node LTS com cache npm → `npm ci` → `typecheck` → `lint` → `test:ci` (com cobertura). Job separado `android-build`: JDK 17 + `npx expo prebuild --platform android --clean` + `./gradlew assembleRelease` (cache do Gradle), upload do APK como artifact. Se for lento demais em todo push, rode `android-build` só em PR para `main`, em push na `main` e por `workflow_dispatch`.
   - `release.yml` (tag `v*` e `workflow_dispatch`): decodifica `KEYSTORE_BASE64`, injeta `EXPO_PUBLIC_SUPABASE_*` dos secrets (se existirem), `APP_VERSION` a partir da tag e `APP_VERSION_CODE` = `github.run_number`, prebuild + `assembleRelease`, confere com `apksigner verify --print-certs`, renomeia para `OficinaDoPaulo-v{versão}.apk` e cria o **GitHub Release** com o APK anexado.

## Plano de testes mínimo (QA)

- Unit: `formatarCentavos` (0, 5, 100, 123456, 100000000, negativo), `parseValor` ("12,50", "1.234,56", "R$ 10", "", "abc", "12,555").
- RNTL: layout de abas renderiza as 4 abas; tocar em cada uma mostra o título correto (use `expo-router/testing-library` ou teste as telas isoladas).
- RNTL: `StatusPagamentoChip` mostra texto e ícone corretos para os 3 status, em tema claro e escuro.
- CI: `android-build` gera APK. Release: disparar `release.yml` via `workflow_dispatch` e confirmar APK **assinado com o keystore de produção** (comparar o SHA-256 do certificado com `certificado.pem` da pasta do keystore). Apagar o release de teste depois, se criado.

## Critério de pronto

Local e CI verdes na `main`, APK disponível como artifact, release de teste assinado corretamente, `STATUS.md` criado.

# Oficina do Paulo

App Android (React Native + Expo) para a oficina mecânica **Oficina do Paulo** controlar clientes, veículos, serviços e pagamentos — e saber, sem erro, se cada serviço foi pago.

Especificação e fases de desenvolvimento em [`agentes/`](agentes/); progresso em [`STATUS.md`](STATUS.md).

## Desenvolvimento

```bash
npm install
npm run typecheck   # TypeScript strict
npm run lint        # ESLint + Prettier
npm test            # Jest (+ Testing Library)
npm run test:ci     # Jest com cobertura
npm run format      # formata o código
```

Copie `.env.example` para `.env` para apontar para o Supabase (opcional; sem ele o app mostra "Servidor não configurado").

## Build e release

O APK é gerado **só no GitHub Actions** (`npx expo prebuild` + Gradle); não é preciso Java/Android SDK local.

- `ci.yml`: typecheck, lint, testes em todo push; build do APK em PR para `main`, push na `main` e manual.
- `release.yml`: tag `v*` ou execução manual → APK assinado com o keystore de produção, conferido com `apksigner`, publicado no GitHub Release como `OficinaDoPaulo-v{versão}.apk`.

A assinatura é feita pelo config plugin `plugins/withAndroidSigning.js` com as variáveis `ANDROID_KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` e `KEY_PASSWORD` (secrets do repositório). Sem elas o release usa a assinatura debug.

Os ícones e a splash são gerados por `node scripts/gerar-icones.mjs`.

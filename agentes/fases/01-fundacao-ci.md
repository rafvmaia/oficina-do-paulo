# Fase 01 — Fundação, tema e CI/CD

**Papel:** engenheiro Android + DevOps + QA.

## Escopo

1. **Repositório**
   - `git init`, `.gitignore` Android/Kotlin (incluindo `*.jks`, `*.p12`, `keystore.properties`, `local.properties`).
   - Criar repositório **público** `oficina-do-paulo` no GitHub com `gh repo create` e fazer push da `main` (público para o link de download do APK funcionar sem login; nenhum segredo vai no código).
   - A pasta `agentes/` e o `PROMPT-APP-OFICINA.md` ficam versionados na raiz do repo, **sem mudar de lugar** (os outros agentes leem desses caminhos).
2. **Projeto Android** compilável: Gradle KTS, version catalog, pacote `br.com.oficinadopaulo`, wrapper funcional (ver CONTEXTO.md).
3. **Tema**: cores claro/escuro, tipografia, shapes do CONTEXTO.md; ícone adaptive; splash.
4. **Componentes base** (em `ui/components`):
   - `StatusPagamentoChip(status)` — cor + ícone + texto, `testTag("chip_status_pagamento")`
   - `Dinheiro` utilitário: `formatarCentavos(Long): String` e `parseValor(String): Long?`
   - `BotaoPrincipal` (56dp), `CampoTexto` com erro, `EstadoVazio(icone, texto)`, `DialogoConfirmacao`
5. **Navegação**: barra inferior com **Início, Clientes, A Receber, Serviços** + ícone de Configurações na top bar. Telas ainda simples, mas com estado vazio real (nada de "em construção").
6. **CI/CD** em `.github/workflows/`:
   - `ci.yml` (push e PR): JDK 17, cache Gradle, `assembleDebug`, `testDebugUnitTest`, `lintDebug`, upload do APK debug e relatórios de teste como artifacts.
   - `release.yml` (tag `v*` e `workflow_dispatch`): decodifica keystore dos Secrets, `assembleRelease` assinado, minify + shrinkResources, renomeia para `OficinaDoPaulo-v{versionName}.apk`, cria **GitHub Release** com o APK anexado. `versionName` vem da tag; `versionCode` do número do run.
7. **Keystore** sem Java local: gerar com `openssl` um par RSA 2048 + certificado autoassinado de 30 anos, exportar **PKCS12** (`storeType "pkcs12"` no `signingConfig`). Salvar em `~/Documents/OficinaDoPaulo-keystore/` (FORA do repo) com um `LEIA-ME.txt` contendo alias e senhas. Gravar os 4 secrets com `gh secret set`.

## Plano de testes mínimo (QA)

- Unit: `formatarCentavos` (0, 5, 100, 123456, 100000000, negativo), `parseValor` ("12,50", "1.234,56", "R$ 10", "", "abc", "12,555").
- Robolectric: app abre; navega pelas 4 abas; cada aba mostra título correto.
- Robolectric: `StatusPagamentoChip` exibe texto e ícone corretos para os 3 status, em tema claro e escuro.
- Release: disparar `release.yml` via `workflow_dispatch` e confirmar que gera APK **assinado** (verificar com `apksigner verify` dentro do job). Apagar o release de teste depois, se criado.

## Critério de pronto

CI verde na `main`, APK debug disponível como artifact, release de teste assinado com sucesso, keystore salvo fora do repo, `STATUS.md` criado.

# Protocolo Dev + QA — obrigatório em toda fase

Cada agente é ao mesmo tempo **desenvolvedor e engenheiro de QA** da sua fase. Desenvolver e testar acontecem juntos, não em sequência.

## Fluxo de cada fase

1. **Ler**: `agentes/CONTEXTO.md`, este arquivo, o arquivo da fase, `STATUS.md` e os `docs/qa/` das fases anteriores.
2. **Plano de testes primeiro**: criar `docs/qa/fase-NN.md` com a lista de casos de teste (caminho feliz, erros, bordas, offline) **antes** de implementar.
3. **Branch**: `fase-NN-nome` a partir de `main` atualizada.
4. **Ciclo curto local**: implemente uma parte pequena → escreva os testes dela → `npx tsc --noEmit && npm run lint && npm test` → corrija → commit. Não acumule a fase inteira para testar no fim.
5. **CI**: push frequente; acompanhe com `gh run watch` e leia falhas com `gh run view --log-failed`.
6. **Pull request** para `main` com descrição do que foi feito e checklist de QA marcado.
7. **Gate (critério de pronto)** — só faz merge se TUDO for verdade:
   - Local e CI verdes: typecheck, lint, Jest (e pgTAP / build do APK quando a fase mexer nisso)
   - Todos os casos do plano de testes foram automatizados ou justificados no `docs/qa/fase-NN.md`
   - Checklist de revisão abaixo conferido
   - Nenhum teste de fase anterior foi apagado, pulado (`.skip`) ou afrouxado para "passar"
8. **Merge** (squash, `gh pr merge --squash --delete-branch`) → confirmar CI verde também na `main`.
9. **Registrar**: atualizar `docs/qa/fase-NN.md` (resultado, nº de testes, link do run) e `STATUS.md` (fase concluída, pendências, bloqueios).

## Checklist de revisão (QA manual em código)

- [ ] Textos em pt-BR, sem erro de português, sem texto em inglês visível
- [ ] Dinheiro em centavos inteiros; exibição `R$ 1.234,56`; nada de `toFixed` em soma de reais
- [ ] Status de pagamento com cor + ícone + texto
- [ ] Área de toque ≥ 48dp; elementos interativos com `accessibilityLabel`
- [ ] Funciona no modo escuro (pelo menos um teste de tela com tema escuro por fase de UI)
- [ ] Estados de carregando, vazio e erro tratados
- [ ] Ações destrutivas pedem confirmação
- [ ] Funciona offline (escreve no SQLite; sync depois)
- [ ] Teclado não cobre campos (`KeyboardAvoidingView`/scroll)
- [ ] Nenhum segredo commitado; nenhum `TODO`/tela "em construção"; nenhum `any` sem justificativa

## Regras de qualidade

- Bug encontrado em fase anterior: corrija nesta fase **com um teste de regressão** e registre em `STATUS.md`.
- Testes de tela usam `testID`s estáveis (ex.: `chip-status-pagamento`, `btn-marcar-pago`).
- Lógica de negócio fica fora dos componentes (em `src/domain`, repositórios ou hooks), para ser testável sem tela.
- Se o CI falhar 5 vezes seguidas pelo mesmo motivo sem progresso: registre em `STATUS.md` → seção **BLOQUEIOS** com o erro e o que foi tentado, e devolva ao orquestrador.
- Commits terminam com `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; PRs terminam com `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

## Relatório final da fase (resposta ao orquestrador)

Responda em no máximo 15 linhas: o que foi entregue, nº de testes adicionados, link do PR, link do run verde da `main`, pendências/bloqueios.

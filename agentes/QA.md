# Protocolo Dev + QA — obrigatório em toda fase

Cada agente é ao mesmo tempo **desenvolvedor e engenheiro de QA** da sua fase. Desenvolver e testar acontecem juntos, não em sequência.

## Fluxo de cada fase

1. **Ler**: `agentes/CONTEXTO.md`, este arquivo, o arquivo da fase, `STATUS.md` e os `docs/qa/` das fases anteriores.
2. **Plano de testes primeiro**: criar `docs/qa/fase-NN.md` com a lista de casos de teste (caminho feliz, erros, bordas, offline) **antes** de implementar.
3. **Branch**: `fase-NN-nome` a partir de `main` atualizada.
4. **Ciclo curto**: implemente uma parte pequena → escreva os testes dela → commit → push → `gh run watch` → corrija. Não acumule a fase inteira para testar no fim.
5. **Pull request** para `main` com descrição do que foi feito e checklist de QA marcado.
6. **Gate (critério de pronto)** — só faz merge se TUDO for verdade:
   - CI verde: build, testes unitários, testes de tela (Robolectric), lint (e pgTAP quando houver SQL)
   - Todos os casos do plano de testes foram automatizados ou justificados no `docs/qa/fase-NN.md`
   - Checklist de revisão abaixo conferido
   - Nenhum teste de fase anterior foi apagado ou desativado para "passar"
7. **Merge** (squash) → confirmar CI verde também na `main`.
8. **Registrar**: atualizar `docs/qa/fase-NN.md` (resultado, nº de testes, link do run) e `STATUS.md` (fase concluída, pendências, bloqueios).

## Checklist de revisão (QA manual em código)

- [ ] Textos em pt-BR, sem erro de português, sem texto em inglês visível
- [ ] Valores em centavos; exibição `R$ 1.234,56`; nunca `Double` para dinheiro
- [ ] Status de pagamento com cor + ícone + texto
- [ ] Área de toque ≥ 48dp; ícones com `contentDescription`
- [ ] Funciona no modo escuro (pelo menos um teste de tela com tema escuro por fase de UI)
- [ ] Estados de carregando, vazio e erro tratados
- [ ] Ações destrutivas pedem confirmação
- [ ] Funciona offline (escreve no Room; sync depois)
- [ ] Nenhum segredo commitado; nenhum `TODO`/tela "em construção"
- [ ] Rotação de tela não perde o que foi digitado

## Regras de qualidade

- Bug encontrado em fase anterior: corrija nesta fase **com um teste de regressão** e registre em `STATUS.md`.
- Testes de tela usam `testTag`s estáveis (ex.: `chip_status_pagamento`, `btn_marcar_pago`).
- Lógica de negócio fica fora dos Composables (ViewModel / domínio), para ser testável.
- Se o CI falhar 5 vezes seguidas pelo mesmo motivo sem progresso: registre em `STATUS.md` → seção **BLOQUEIOS** com o erro e o que foi tentado, e devolva ao orquestrador.

## Relatório final da fase (resposta ao orquestrador)

Responda em no máximo 15 linhas: o que foi entregue, nº de testes adicionados, link do PR, link do run verde da `main`, pendências/bloqueios.

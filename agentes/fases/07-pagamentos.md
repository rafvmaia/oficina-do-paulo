# Fase 07 — Pagamentos ⚠️ FASE CRÍTICA

**Papel:** engenheiro Android + QA com rigor máximo. Esta é a funcionalidade **imprescindível** do app. Na dúvida, teste mais.

## Escopo

1. **Área de pagamentos** no detalhe do serviço:
   - Valores grandes: **Total**, **Pago**, **Falta pagar** (vermelho se > 0, verde se 0).
   - Barra de progresso pago/total.
   - `StatusPagamentoChip` grande no topo da tela.
2. **Botão "Marcar como pago"** (`testTag("btn_marcar_pago")`, 56dp, laranja), visível quando status ≠ PAGO:
   - Um toque abre diálogo rápido: valor = falta (somente leitura), forma (Pix pré-selecionado), data = hoje → **Confirmar**.
   - Botão desabilitado enquanto grava (**nunca** gerar pagamento duplicado com toque duplo).
3. **Botão "Pagamento parcial"**: valor (máscara R$), forma, data, observação. Valor maior que a falta → erro "Valor maior que o restante (R$ X)". Valor 0 → erro.
4. **Histórico**: lista de pagamentos (data, forma, valor, observação). Excluir lançamento com confirmação + Snackbar **Desfazer**.
5. **Desfazer pagamento total**: em serviço PAGO, ação "Desmarcar pagamento" que exclui o(s) último(s) lançamento(s) após confirmação.
6. **Ficha do cliente**: card de resumo **Total em serviços / Total pago / Em aberto** (vermelho se > 0) e filtro dos serviços por status de pagamento.
7. Consistência: após qualquer pagamento, o status muda **ao mesmo tempo** em: detalhe, lista de serviços, ficha do cliente, lista de clientes (indicador), e nos agregados usados por A Receber / Início.

## Plano de testes (mínimo — ampliar se achar lacunas)

- Matriz de status: (sem pagamento | parcial | exato | a mais via sync | excluído) × (total 0 | total > 0).
- Marcar como pago: cria 1 pagamento com valor = falta; status vira PAGO; falta = 0.
- **Toque duplo / dois toques rápidos** no Confirmar → continua 1 pagamento só.
- Parcial + parcial + marcar como pago → soma exata, PAGO.
- Valor parcial maior que a falta é bloqueado; 0 bloqueado; "1.234,56" vira 123456 centavos.
- Excluir pagamento → volta para PARCIAL/PENDENTE; Desfazer → volta para PAGO.
- Desmarcar pagamento em serviço PAGO.
- Edição do serviço aumentando o total depois de pago → vira PARCIAL com a nova falta.
- Offline: marcar como pago sem rede → status muda na hora; pagamento fica pendente de sync; com FakeRemote, sincroniza depois.
- Robolectric ponta a ponta: criar cliente → serviço R$ 350,00 → parcial R$ 100,00 (chip PARCIAL, falta R$ 250,00) → marcar como pago (chip PAGO) → conferir chip na lista de Serviços e no resumo da ficha do cliente.
- Acessibilidade: chip e botões com `contentDescription` lendo o status e o valor.
- Tema escuro do detalhe com cada status.

## Critério de pronto

CI verde; todos os casos acima automatizados; `docs/qa/fase-07.md` com a matriz de casos marcada.

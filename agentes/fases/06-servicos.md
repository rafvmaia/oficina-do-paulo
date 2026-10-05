# Fase 06 — Serviços

**Papel:** engenheiro Android + QA.

## Escopo

1. **Cadastro/edição de serviço**: escolher cliente (busca) e veículo do cliente (opcional); descrição*; peças (texto livre); mão de obra e valor de peças com máscara `R$`; **total calculado ao vivo**; status do serviço; data de entrada (hoje por padrão) e de conclusão; observações.
   - Checkbox **"Já foi pago"**: ao salvar, cria um pagamento do valor total (escolher forma, Pix pré-selecionado).
   - Atalho "Novo serviço" a partir da ficha do cliente já preenche o cliente.
2. **Aba Serviços**: lista com cliente, veículo, descrição, total, data e **`StatusPagamentoChip`**; filtros por status do serviço, status de pagamento e período (este mês / mês passado / personalizado).
3. **Detalhe do serviço**: cabeçalho com cliente, veículo, valores e status; ações editar, alterar status do serviço, excluir (com confirmação e desfazer). Reservar a **área de pagamentos** (implementada na fase 07) — já mostrando total, pago e falta reais.
4. Ficha do cliente passa a listar os serviços dele com chip de status.

## Plano de testes

- Cálculo do total ao digitar (inclui campos vazios e centavos).
- Validação: descrição e cliente obrigatórios; valores negativos impossíveis.
- "Já foi pago" gera exatamente 1 pagamento e o serviço aparece como PAGO.
- Filtros combinados retornam o esperado.
- Robolectric: criar serviço pela aba e pela ficha do cliente; editar; excluir/desfazer; chip correto na lista; tema escuro.

## Critério de pronto

CI verde; serviço criado aparece na lista, na ficha do cliente e no detalhe com valores consistentes.

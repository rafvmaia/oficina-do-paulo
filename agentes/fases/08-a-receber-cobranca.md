# Fase 08 — A Receber e cobrança por WhatsApp

**Papel:** engenheiro Android + QA.

## Escopo

1. **Aba A Receber**:
   - Topo: **Total em aberto** (soma das faltas) e quantidade de serviços.
   - Lista dos serviços PENDENTE e PARCIAL, do mais antigo para o mais novo: cliente, telefone, descrição, falta, chip, **"há N dias"** (destaque âmbar > 15 dias, vermelho > 30 dias).
   - Ação rápida em cada item: **Marcar como pago** (mesmo diálogo/lógica da fase 07 — reutilizar, não duplicar) e **Cobrar**.
   - Alternar visão "por serviço" / "por cliente" (agrupado, com total por cliente).
   - Estado vazio comemorativo: "Tudo recebido! Nenhum valor em aberto."
2. **Cobrar pelo WhatsApp** (no item da lista, no detalhe do serviço e na ficha do cliente):
   - Abre `https://wa.me/55<numero>?text=<mensagem codificada>`:
     `Olá, {nome}! Aqui é da Oficina do Paulo. Consta em aberto o valor de R$ {falta} referente a {descricao}. Qualquer dúvida estou à disposição.`
   - Na ficha do cliente, se houver vários serviços em aberto, a mensagem lista cada um e o total.
   - Sem telefone válido → mensagem explicando.

## Plano de testes

- Ordenação por data; cálculo de dias; limiares de cor.
- Total em aberto bate com a soma das faltas (inclui parciais).
- Marcar como pago a partir da lista remove o item e reduz o total na hora.
- Mensagem de cobrança: acentos, `R$` e quebras de linha codificados corretamente na URL; versão com vários serviços.
- Robolectric: lista, agrupamento por cliente, ação rápida, estado vazio, tema escuro.

## Critério de pronto

CI verde; A Receber consistente com detalhe e ficha do cliente.

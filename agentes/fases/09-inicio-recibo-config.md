# Fase 09 — Início (dashboard), recibo em PDF e configurações

**Papel:** engenheiro React Native + QA.

## Escopo

1. **Início**:
   - Cards: **A receber** (total, toque → aba A Receber), **Recebido no mês** (soma de pagamentos do mês corrente), **Em andamento** (qtd. serviços EM_ANDAMENTO), **Serviços do mês**.
   - Últimos 5 serviços com chip de status; FAB "Novo serviço".
2. **Recibo em PDF** (detalhe do serviço, quando houver pagamento):
   - Gerar com `expo-print` a partir de um template HTML: cabeçalho "Oficina do Paulo", data, cliente, veículo, descrição, peças, mão de obra, total, lista de pagamentos, total pago, falta, status.
   - Abrir compartilhamento com `expo-sharing`, pronto para WhatsApp.
3. **Configurações** (complementa a fase 04):
   - Dados da oficina para o recibo: nome, telefone, endereço, CNPJ (salvos localmente).
   - **Exportar planilha CSV** de clientes, serviços e pagamentos (compartilhar arquivo).
   - Somente em modo desenvolvimento (`__DEV__`): "Carregar dados de demonstração" e "Apagar dados locais".

## Plano de testes

- Agregados do Início com datas na virada do mês e fuso `America/Sao_Paulo`.
- Recibo: função que monta o HTML do recibo contém todos os campos e valores formatados (testar o modelo de dados separado da impressão; `expo-print` mockado).
- CSV: cabeçalhos, separador `;`, valores `1234,56`, acentos em UTF-8 com BOM (abre certo no Excel).
- RNTL: Início com dados e vazio; navegação do card para A Receber; tema escuro.

## Critério de pronto

Local e CI verdes; recibo compartilhável; nenhuma tela com placeholder em todo o app.

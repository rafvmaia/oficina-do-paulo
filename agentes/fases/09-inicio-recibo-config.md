# Fase 09 — Início (dashboard), recibo em PDF e configurações

**Papel:** engenheiro Android + QA.

## Escopo

1. **Início**:
   - Cards: **A receber** (total, toque → aba A Receber), **Recebido no mês** (soma de pagamentos do mês corrente), **Em andamento** (qtd. serviços EM_ANDAMENTO), **Serviços do mês**.
   - Últimos 5 serviços com chip de status; FAB "Novo serviço".
2. **Recibo em PDF** (detalhe do serviço, quando houver pagamento):
   - Gerar com `PdfDocument` do Android: cabeçalho "Oficina do Paulo", data, cliente, veículo, descrição, peças, mão de obra, total, lista de pagamentos, total pago, falta, status.
   - Salvar no cache e abrir compartilhamento (`FileProvider` + `ACTION_SEND`), pronto para WhatsApp.
3. **Configurações** (complementa a fase 04):
   - Dados da oficina para o recibo: nome, telefone, endereço, CNPJ (salvos em DataStore).
   - **Exportar planilha CSV** de clientes, serviços e pagamentos (compartilhar arquivo).
   - Somente em build debug: "Carregar dados de demonstração" e "Apagar dados locais".

## Plano de testes

- Agregados do Início com datas na virada do mês e fuso `America/Sao_Paulo`.
- Recibo: gerador produz PDF não vazio com 1 página; conteúdo textual (testar o modelo de dados do recibo separado do desenho).
- CSV: cabeçalhos, separador `;`, valores `1234,56`, acentos em UTF-8 com BOM (abre certo no Excel).
- Robolectric: Início com dados e vazio; navegação do card para A Receber; tema escuro.

## Critério de pronto

CI verde; recibo compartilhável; nenhuma tela com placeholder em todo o app.

# Fase 05 — Clientes e veículos

**Papel:** engenheiro React Native + QA.

## Escopo

1. **Lista de clientes** (aba Clientes): busca instantânea por nome, telefone ou placa; cada item com nome, telefone e um indicador vermelho "Em aberto R$ X" quando houver débito; ordenação alfabética; FAB "Novo cliente"; estado vazio.
2. **Cadastro/edição de cliente**: nome* e telefone* obrigatórios; máscara de telefone `(11) 91234-5678`; CPF/CNPJ com máscara e validação de dígitos (opcional); endereço; observações. Salvar desabilitado enquanto inválido. Teclado não cobre os campos.
3. **Veículos**: dentro do cliente, adicionar/editar/remover veículos; placa no padrão antigo `ABC-1234` e Mercosul `ABC1D23` (normalizar para maiúsculas).
4. **Ficha do cliente**: dados, botões **Ligar** (`Linking` com `tel:`) e **WhatsApp** (`https://wa.me/55<numero>`), lista de veículos, área reservada para o resumo financeiro e lista de serviços (preenchidas nas fases 06/07 — já deixar os componentes recebendo dados reais, mostrando estado vazio).
5. **Excluir cliente**: diálogo de confirmação dizendo quantos serviços/pagamentos serão excluídos juntos; Snackbar com "Desfazer".

## Plano de testes

- Validadores: telefone, CPF, CNPJ, placa (válidos e inválidos).
- Hooks/lógica: busca, salvar novo, editar, excluir e desfazer.
- RNTL: fluxo completo cadastrar → aparece na lista → buscar por placa → editar → excluir → desfazer; mensagem de erro em campo obrigatório; estado vazio; tema escuro.
- URLs de Ligar e WhatsApp montadas com número correto (teste unitário da função que gera a URL).

## Critério de pronto

Local e CI verdes; nenhuma tela de cliente com placeholder.

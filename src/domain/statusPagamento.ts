/** Status de pagamento de um serviço (sempre derivado dos pagamentos, nunca gravado). */
export type StatusPagamento = 'PAGO' | 'PARCIAL' | 'PENDENTE';

export const STATUS_PAGAMENTO: readonly StatusPagamento[] = ['PAGO', 'PARCIAL', 'PENDENTE'];

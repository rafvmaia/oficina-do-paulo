package br.com.oficinadopaulo.domain

/**
 * Situação de pagamento de um serviço. É sempre **derivada** da soma dos pagamentos
 * (nunca gravada à mão).
 */
enum class StatusPagamento(val rotulo: String) {
    PAGO("PAGO"),
    PARCIAL("PARCIAL"),
    PENDENTE("PENDENTE"),
}

package br.com.oficinadopaulo.ui.components

/**
 * Formatação e leitura de valores em dinheiro.
 *
 * Todo valor do app é guardado em **centavos (Long)**; nunca usamos `Double` para dinheiro.
 * A exibição segue o padrão brasileiro: `R$ 1.234,56`.
 */
object Dinheiro {

    private const val PREFIXO = "R$ "
    private val SOMENTE_DIGITOS = Regex("""^\d+(,\d{1,2})?$""")
    private val COM_MILHAR = Regex("""^\d{1,3}(\.\d{3})+(,\d{1,2})?$""")
    // Ponto seguido de 1 ou 2 dígitos é decimal ("10.50"); com 3 dígitos é milhar ("1.000").
    private val PONTO_DECIMAL = Regex("""^\d+\.\d{1,2}$""")

    /** Ex.: `123456` → `"R$ 1.234,56"`; `-1050` → `"-R$ 10,50"`. */
    fun formatarCentavos(centavos: Long): String {
        val negativo = centavos < 0
        // Usa a forma "unsigned" para não estourar em Long.MIN_VALUE.
        val absoluto = if (negativo) (-centavos).toULong() else centavos.toULong()
        val reais = (absoluto / 100u).toString()
        val resto = (absoluto % 100u).toString().padStart(2, '0')
        val reaisComMilhar = reais.reversed().chunked(3).joinToString(".").reversed()
        return (if (negativo) "-" else "") + PREFIXO + reaisComMilhar + "," + resto
    }

    /**
     * Converte o texto digitado pelo usuário em centavos. Retorna `null` se o texto for inválido.
     *
     * Aceita: `"12,50"`, `"12,5"`, `"1.234,56"`, `"R$ 10"`, `"1.000"` (milhar) e `"10.50"`
     * (ponto como decimal, quando seguido de 1 ou 2 dígitos). Não aceita valores negativos,
     * mais de 2 casas decimais, texto vazio ou valores que não cabem em `Long`.
     */
    fun parseValor(texto: String): Long? {
        val limpo = texto
            .replace("R$", "", ignoreCase = true)
            .replace(' ', ' ')
            .replace(" ", "")
            .trim()
        if (limpo.isEmpty()) return null

        val (inteiro, decimal) = when {
            SOMENTE_DIGITOS.matches(limpo) || COM_MILHAR.matches(limpo) -> {
                val partes = limpo.replace(".", "").split(',')
                partes[0] to partes.getOrElse(1) { "" }
            }
            PONTO_DECIMAL.matches(limpo) -> {
                val partes = limpo.split('.')
                partes[0] to partes[1]
            }
            else -> return null
        }

        val reais = inteiro.toLongOrNull() ?: return null
        val centavos = decimal.padEnd(2, '0').toLong()
        if (reais > (Long.MAX_VALUE - centavos) / 100) return null
        return reais * 100 + centavos
    }
}

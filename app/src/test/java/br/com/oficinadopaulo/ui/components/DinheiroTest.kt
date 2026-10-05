package br.com.oficinadopaulo.ui.components

import br.com.oficinadopaulo.ui.components.Dinheiro.formatarCentavos
import br.com.oficinadopaulo.ui.components.Dinheiro.parseValor
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class DinheiroTest {

    // ---- formatarCentavos ----

    @Test fun formata_zero() = assertEquals("R$ 0,00", formatarCentavos(0))

    @Test fun formata_cinco_centavos() = assertEquals("R$ 0,05", formatarCentavos(5))

    @Test fun formata_um_real() = assertEquals("R$ 1,00", formatarCentavos(100))

    @Test fun formata_com_milhar() = assertEquals("R$ 1.234,56", formatarCentavos(123456))

    @Test fun formata_um_milhao() = assertEquals("R$ 1.000.000,00", formatarCentavos(100_000_000))

    @Test fun formata_negativo() {
        assertEquals("-R$ 10,50", formatarCentavos(-1050))
        assertEquals("-R$ 0,01", formatarCentavos(-1))
    }

    @Test fun formata_limites_de_long_sem_estourar() {
        assertEquals("R$ 92.233.720.368.547.758,07", formatarCentavos(Long.MAX_VALUE))
        assertEquals("-R$ 92.233.720.368.547.758,08", formatarCentavos(Long.MIN_VALUE))
    }

    @Test fun formata_centenas_e_dezenas_de_milhar() {
        assertEquals("R$ 999,99", formatarCentavos(99_999))
        assertEquals("R$ 10.000,00", formatarCentavos(1_000_000))
        assertEquals("R$ 100.000,10", formatarCentavos(10_000_010))
    }

    // ---- parseValor ----

    @Test fun le_virgula_decimal() = assertEquals(1250L, parseValor("12,50"))

    @Test fun le_milhar_e_decimal() = assertEquals(123456L, parseValor("1.234,56"))

    @Test fun le_com_prefixo_reais() {
        assertEquals(1000L, parseValor("R$ 10"))
        assertEquals(1000L, parseValor("R$10"))
        assertEquals(123456L, parseValor("R$ 1.234,56"))
    }

    @Test fun vazio_e_invalido() {
        assertNull(parseValor(""))
        assertNull(parseValor("   "))
        assertNull(parseValor("R$"))
    }

    @Test fun texto_nao_numerico_e_invalido() = assertNull(parseValor("abc"))

    @Test fun tres_casas_decimais_e_invalido() = assertNull(parseValor("12,555"))

    @Test fun formatos_validos_diversos() {
        assertEquals(1250L, parseValor("12,5"))
        assertEquals(5L, parseValor("0,05"))
        assertEquals(100_000L, parseValor("1.000"))
        assertEquals(1050L, parseValor("10.50"))
        assertEquals(0L, parseValor("0"))
        assertEquals(100_000_000L, parseValor("1.000.000,00"))
        assertEquals(1250L, parseValor("  12,50  "))
    }

    @Test fun formatos_invalidos_diversos() {
        assertNull(parseValor("-10"))
        assertNull(parseValor("1.23,00"))
        assertNull(parseValor("12,"))
        assertNull(parseValor(",50"))
        assertNull(parseValor("1,234,56"))
        assertNull(parseValor("12.34.56"))
        assertNull(parseValor("10 reais"))
        assertNull(parseValor("99999999999999999999"))
        assertNull(parseValor("92.233.720.368.547.758,08"))
    }

    @Test fun maior_valor_que_cabe_em_long() =
        assertEquals(Long.MAX_VALUE, parseValor("92.233.720.368.547.758,07"))

    @Test fun ida_e_volta_formatar_e_ler() {
        listOf(0L, 1L, 5L, 99L, 100L, 1050L, 123456L, 100_000_000L, 987_654_321L).forEach { valor ->
            assertEquals("ida e volta de $valor", valor, parseValor(formatarCentavos(valor)))
        }
    }
}

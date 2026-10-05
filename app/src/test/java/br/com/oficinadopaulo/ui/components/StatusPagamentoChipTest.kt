package br.com.oficinadopaulo.ui.components

import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.graphics.Color
import androidx.test.ext.junit.runners.AndroidJUnit4
import br.com.oficinadopaulo.domain.StatusPagamento
import br.com.oficinadopaulo.ui.theme.OficinaTheme
import br.com.oficinadopaulo.ui.theme.Paleta
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class StatusPagamentoChipTest {

    @get:Rule val regra = createComposeRule()

    private fun verificar(status: StatusPagamento, temaEscuro: Boolean, corEsperada: Color, texto: String) {
        regra.setContent {
            OficinaTheme(temaEscuro = temaEscuro) { StatusPagamentoChip(status) }
        }
        regra.onNodeWithTag("chip_status_pagamento")
            .assertIsDisplayed()
            .assertTextEquals(texto)
            .assert(SemanticsMatcher.expectValue(CorStatusKey, corEsperada))

        val tagsIcones = StatusPagamento.entries.associateWith { "icone_status_${it.name.lowercase()}" }
        tagsIcones.forEach { (outro, tag) ->
            val no = regra.onNodeWithTag(tag, useUnmergedTree = true)
            if (outro == status) no.assertIsDisplayed() else no.assertDoesNotExist()
        }
    }

    @Test fun pago_tema_claro() = verificar(StatusPagamento.PAGO, false, Paleta.PagoClaro, "PAGO")

    @Test fun parcial_tema_claro() = verificar(StatusPagamento.PARCIAL, false, Paleta.ParcialClaro, "PARCIAL")

    @Test fun pendente_tema_claro() = verificar(StatusPagamento.PENDENTE, false, Paleta.PendenteClaro, "PENDENTE")

    @Test fun pago_tema_escuro() = verificar(StatusPagamento.PAGO, true, Paleta.PagoEscuro, "PAGO")

    @Test fun parcial_tema_escuro() = verificar(StatusPagamento.PARCIAL, true, Paleta.ParcialEscuro, "PARCIAL")

    @Test fun pendente_tema_escuro() = verificar(StatusPagamento.PENDENTE, true, Paleta.PendenteEscuro, "PENDENTE")
}

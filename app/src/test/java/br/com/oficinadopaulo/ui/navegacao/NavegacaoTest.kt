package br.com.oficinadopaulo.ui.navegacao

import androidx.compose.ui.test.assertHeightIsAtLeast
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.assertWidthIsAtLeast
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import br.com.oficinadopaulo.ui.telas.TextosVazios
import br.com.oficinadopaulo.ui.theme.OficinaTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class NavegacaoTest {

    @get:Rule val regra = createComposeRule()

    private val textoVazioPorAba = mapOf(
        Aba.INICIO to TextosVazios.INICIO,
        Aba.CLIENTES to TextosVazios.CLIENTES,
        Aba.A_RECEBER to TextosVazios.A_RECEBER,
        Aba.SERVICOS to TextosVazios.SERVICOS,
    )

    private fun abrirApp(temaEscuro: Boolean = false, servidorConfigurado: Boolean = false) {
        regra.setContent {
            OficinaTheme(temaEscuro = temaEscuro) {
                OficinaApp(
                    servidorConfigurado = servidorConfigurado,
                    versaoApp = "1.2.3",
                    mostrarAbertura = false,
                )
            }
        }
    }

    private fun percorrerAbas() {
        // Ida e volta para garantir que todas as transições funcionam.
        (Aba.entries + Aba.entries.reversed()).forEach { aba ->
            regra.onNodeWithTag(aba.tag).performClick()
            regra.onNodeWithTag(aba.tag).assertIsSelected()
            regra.onNodeWithTag("titulo_tela").assertTextEquals(aba.titulo)
            regra.onNodeWithText(textoVazioPorAba.getValue(aba)).assertIsDisplayed()
        }
    }

    @Test fun abre_na_aba_inicio_com_quatro_abas() {
        abrirApp()
        regra.onNodeWithTag("titulo_tela").assertTextEquals("Início")
        Aba.entries.forEach { regra.onNodeWithTag(it.tag).assertIsDisplayed() }
        regra.onNodeWithTag(Aba.INICIO.tag).assertIsSelected()
        regra.onNodeWithText(TextosVazios.INICIO).assertIsDisplayed()
    }

    @Test fun navega_pelas_quatro_abas_com_titulo_e_estado_vazio_corretos() {
        abrirApp()
        percorrerAbas()
    }

    @Test fun navega_pelas_quatro_abas_no_tema_escuro() {
        abrirApp(temaEscuro = true)
        percorrerAbas()
    }

    @Test fun abre_configuracoes_e_volta_para_a_aba_anterior() {
        abrirApp()
        regra.onNodeWithTag(Aba.CLIENTES.tag).performClick()
        regra.onNodeWithTag("btn_configuracoes").performClick()

        regra.onNodeWithTag("titulo_tela").assertTextEquals("Configurações")
        regra.onNodeWithTag("texto_status_servidor").assertTextEquals("Servidor não configurado")
        regra.onNodeWithTag("texto_versao").assertTextEquals("1.2.3")
        regra.onNodeWithTag(Aba.INICIO.tag).assertDoesNotExist()

        regra.onNodeWithTag("btn_voltar").performClick()
        regra.onNodeWithTag("titulo_tela").assertTextEquals("Clientes")
        regra.onNodeWithTag(Aba.CLIENTES.tag).assertIsSelected()
    }

    @Test fun configuracoes_mostra_servidor_configurado() {
        abrirApp(servidorConfigurado = true)
        regra.onNodeWithTag("btn_configuracoes").performClick()
        regra.onNodeWithTag("texto_status_servidor").assertTextEquals("Configurado")
    }

    @Test fun areas_de_toque_tem_pelo_menos_48dp() {
        abrirApp()
        (Aba.entries.map { it.tag } + "btn_configuracoes").forEach { tag ->
            regra.onNodeWithTag(tag)
                .assertHeightIsAtLeast(48.dp)
                .assertWidthIsAtLeast(48.dp)
        }
    }

    @Test fun nenhuma_tela_esta_em_construcao() {
        abrirApp()
        Aba.entries.forEach { aba ->
            regra.onNodeWithTag(aba.tag).performClick()
            regra.onNodeWithText("construção", substring = true, ignoreCase = true).assertDoesNotExist()
        }
    }
}

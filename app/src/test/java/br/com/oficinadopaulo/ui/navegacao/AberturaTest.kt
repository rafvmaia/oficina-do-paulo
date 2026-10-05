package br.com.oficinadopaulo.ui.navegacao

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import br.com.oficinadopaulo.ui.theme.OficinaTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AberturaTest {

    @get:Rule val regra = createComposeRule()

    @Test fun mostra_oficina_do_paulo_e_depois_abre_o_inicio() {
        regra.mainClock.autoAdvance = false
        regra.setContent {
            OficinaTheme { OficinaApp(servidorConfigurado = false, versaoApp = "1.0") }
        }
        regra.onNodeWithTag("tela_abertura").assertIsDisplayed()
        regra.onNodeWithText("Oficina do Paulo").assertIsDisplayed()
        regra.onNodeWithTag(Aba.INICIO.tag).assertDoesNotExist()

        regra.mainClock.advanceTimeBy(DURACAO_ABERTURA_MS + 500)
        regra.mainClock.autoAdvance = true

        regra.onNodeWithTag("tela_abertura").assertDoesNotExist()
        regra.onNodeWithTag(Aba.INICIO.tag).assertIsDisplayed()
    }
}

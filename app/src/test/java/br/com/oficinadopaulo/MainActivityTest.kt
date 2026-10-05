package br.com.oficinadopaulo

import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.test.ext.junit.runners.AndroidJUnit4
import br.com.oficinadopaulo.ui.navegacao.Aba
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityTest {

    @get:Rule val regra = createAndroidComposeRule<MainActivity>()

    @OptIn(ExperimentalTestApi::class)
    @Test fun app_abre_e_mostra_as_quatro_abas() {
        regra.waitUntilExactlyOneExists(hasTestTag(Aba.INICIO.tag), timeoutMillis = 10_000)
        regra.onNodeWithTag("titulo_tela").assertTextEquals("Início")
        Aba.entries.forEach { regra.onNodeWithTag(it.tag).assertIsDisplayed() }
    }
}

package br.com.oficinadopaulo.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.People
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertHeightIsEqualTo
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import br.com.oficinadopaulo.ui.theme.OficinaTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ComponentesBaseTest {

    @get:Rule val regra = createComposeRule()

    @Test fun botao_principal_tem_56dp_e_dispara_clique() {
        var cliques = 0
        regra.setContent { OficinaTheme { BotaoPrincipal("Salvar", onClick = { cliques++ }) } }
        regra.onNodeWithText("Salvar").assertHeightIsEqualTo(56.dp).performClick()
        assertEquals(1, cliques)
    }

    @Test fun botao_principal_desabilitado_nao_clica() {
        var cliques = 0
        regra.setContent {
            OficinaTheme { BotaoPrincipal("Salvar", onClick = { cliques++ }, habilitado = false) }
        }
        regra.onNodeWithText("Salvar").assertIsNotEnabled().performClick()
        assertEquals(0, cliques)
    }

    @Test fun campo_texto_mostra_erro_e_aceita_digitacao() {
        regra.setContent {
            OficinaTheme {
                var texto by remember { mutableStateOf("") }
                CampoTexto(
                    valor = texto,
                    onValorChange = { texto = it },
                    rotulo = "Nome",
                    erro = if (texto.isBlank()) "Informe o nome" else null,
                )
            }
        }
        regra.onNodeWithTag("erro_campo", useUnmergedTree = true).assertTextEquals("Informe o nome")
        regra.onNodeWithText("Nome").assert(SemanticsMatcher.keyIsDefined(SemanticsProperties.Error))

        regra.onNodeWithText("Nome").performTextInput("Paulo")
        regra.onNodeWithTag("erro_campo", useUnmergedTree = true).assertDoesNotExist()
        regra.onNodeWithText("Nome").assert(SemanticsMatcher.keyNotDefined(SemanticsProperties.Error))
    }

    @Test fun estado_vazio_mostra_texto_e_acao() {
        regra.setContent {
            OficinaTheme {
                EstadoVazio(Icons.Filled.People, "Nenhum cliente cadastrado ainda.") { Text("Cadastrar") }
            }
        }
        regra.onNodeWithTag("texto_estado_vazio").assertTextEquals("Nenhum cliente cadastrado ainda.")
        regra.onNodeWithText("Cadastrar").assertIsDisplayed()
    }

    @Test fun dialogo_confirmacao_confirma_e_cancela() {
        var resultado = ""
        regra.setContent {
            OficinaTheme {
                var aberto by remember { mutableStateOf(true) }
                if (aberto) {
                    DialogoConfirmacao(
                        titulo = "Excluir cliente?",
                        mensagem = "Esta ação não pode ser desfeita.",
                        textoConfirmar = "Excluir",
                        destrutivo = true,
                        onConfirmar = { resultado += "confirmou;"; aberto = false },
                        onCancelar = { resultado += "cancelou;"; aberto = false },
                    )
                }
            }
        }
        regra.onNodeWithText("Excluir cliente?").assertIsDisplayed()
        regra.onNodeWithText("Esta ação não pode ser desfeita.").assertIsDisplayed()
        regra.onNodeWithTag("btn_confirmar_dialogo").assertTextEquals("Excluir").performClick()
        regra.onNodeWithTag("dialogo_confirmacao").assertDoesNotExist()
        assertEquals("confirmou;", resultado)
    }

    @Test fun dialogo_confirmacao_cancelar_nao_confirma() {
        var resultado = ""
        regra.setContent {
            OficinaTheme {
                DialogoConfirmacao(
                    titulo = "Excluir?",
                    mensagem = "Tem certeza?",
                    onConfirmar = { resultado += "confirmou;" },
                    onCancelar = { resultado += "cancelou;" },
                )
            }
        }
        regra.onNodeWithTag("btn_cancelar_dialogo").assertTextEquals("Cancelar").performClick()
        assertEquals("cancelou;", resultado)
    }
}

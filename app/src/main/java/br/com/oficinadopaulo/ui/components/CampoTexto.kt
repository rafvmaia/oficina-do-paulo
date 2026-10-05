package br.com.oficinadopaulo.ui.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag

/**
 * Campo de texto com rótulo e mensagem de erro.
 *
 * O estado fica com quem chama (use `rememberSaveable` para não perder o texto na rotação).
 */
@Composable
fun CampoTexto(
    valor: String,
    onValorChange: (String) -> Unit,
    rotulo: String,
    modifier: Modifier = Modifier,
    erro: String? = null,
    dica: String? = null,
    habilitado: Boolean = true,
    linhaUnica: Boolean = true,
    opcoesTeclado: KeyboardOptions = KeyboardOptions.Default,
) {
    OutlinedTextField(
        value = valor,
        onValueChange = onValorChange,
        label = { Text(rotulo) },
        isError = erro != null,
        enabled = habilitado,
        singleLine = linhaUnica,
        keyboardOptions = opcoesTeclado,
        supportingText = when {
            erro != null -> {
                { Text(erro, modifier = Modifier.testTag("erro_campo")) }
            }
            dica != null -> {
                { Text(dica) }
            }
            else -> null
        },
        // isError já marca o campo como inválido na semântica de acessibilidade.
        modifier = modifier.fillMaxWidth(),
    )
}

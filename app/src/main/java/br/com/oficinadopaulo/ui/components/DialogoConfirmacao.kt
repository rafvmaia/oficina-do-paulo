package br.com.oficinadopaulo.ui.components

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag

/** Diálogo para confirmar ações (principalmente as destrutivas, como excluir). */
@Composable
fun DialogoConfirmacao(
    titulo: String,
    mensagem: String,
    onConfirmar: () -> Unit,
    onCancelar: () -> Unit,
    textoConfirmar: String = "Confirmar",
    textoCancelar: String = "Cancelar",
    destrutivo: Boolean = false,
) {
    AlertDialog(
        onDismissRequest = onCancelar,
        title = { Text(titulo) },
        text = { Text(mensagem) },
        confirmButton = {
            TextButton(
                onClick = onConfirmar,
                colors = if (destrutivo) {
                    ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                } else {
                    ButtonDefaults.textButtonColors()
                },
                modifier = Modifier.testTag("btn_confirmar_dialogo"),
            ) { Text(textoConfirmar) }
        },
        dismissButton = {
            TextButton(
                onClick = onCancelar,
                modifier = Modifier.testTag("btn_cancelar_dialogo"),
            ) { Text(textoCancelar) }
        },
        modifier = Modifier.testTag("dialogo_confirmacao"),
    )
}

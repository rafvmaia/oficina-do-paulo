package br.com.oficinadopaulo.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import br.com.oficinadopaulo.ui.theme.OficinaTema

/** Estado vazio de uma lista/tela: ícone grande + texto explicativo (+ conteúdo opcional, ex.: botão). */
@Composable
fun EstadoVazio(
    icone: ImageVector,
    texto: String,
    modifier: Modifier = Modifier,
    acao: (@Composable () -> Unit)? = null,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(32.dp)
            .testTag("estado_vazio"),
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(
            imageVector = icone,
            contentDescription = null,
            tint = OficinaTema.cores.textoSecundario,
            modifier = Modifier.size(72.dp),
        )
        Text(
            text = texto,
            style = MaterialTheme.typography.bodyLarge,
            color = OficinaTema.cores.textoSecundario,
            textAlign = TextAlign.Center,
            modifier = Modifier.testTag("texto_estado_vazio"),
        )
        acao?.invoke()
    }
}

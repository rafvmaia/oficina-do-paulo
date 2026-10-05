package br.com.oficinadopaulo.ui.telas

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import br.com.oficinadopaulo.R
import br.com.oficinadopaulo.ui.theme.Paleta

/** Abertura do app: logo + "Oficina do Paulo" sobre grafite (continua a splash do sistema). */
@Composable
fun TelaAbertura() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Paleta.Grafite)
            .testTag("tela_abertura"),
        verticalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Image(
            painter = painterResource(R.drawable.ic_launcher_foreground),
            contentDescription = "Logotipo da Oficina do Paulo",
            modifier = Modifier.size(160.dp),
        )
        Text(
            text = "Oficina do Paulo",
            style = MaterialTheme.typography.headlineMedium,
            color = Paleta.Branco,
        )
    }
}

package br.com.oficinadopaulo.ui.telas

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.CloudOff
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag

@Composable
fun TelaConfiguracoes(servidorConfigurado: Boolean, versaoApp: String) {
    Column(modifier = Modifier.fillMaxSize().testTag("tela_configuracoes")) {
        ListItem(
            headlineContent = { Text("Servidor") },
            supportingContent = {
                Text(
                    if (servidorConfigurado) "Configurado" else "Servidor não configurado",
                    modifier = Modifier.testTag("texto_status_servidor"),
                )
            },
            leadingContent = {
                Icon(
                    if (servidorConfigurado) Icons.Filled.Cloud else Icons.Filled.CloudOff,
                    contentDescription = null,
                )
            },
        )
        HorizontalDivider()
        ListItem(
            headlineContent = { Text("Versão do app") },
            supportingContent = { Text(versaoApp, modifier = Modifier.testTag("texto_versao")) },
            leadingContent = { Icon(Icons.Filled.Info, contentDescription = null) },
        )
    }
}

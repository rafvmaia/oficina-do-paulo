package br.com.oficinadopaulo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import br.com.oficinadopaulo.ui.navegacao.OficinaApp
import br.com.oficinadopaulo.ui.theme.OficinaTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val container = (application as OficinaApplication).container
        setContent {
            OficinaTheme {
                OficinaApp(
                    servidorConfigurado = container.configuracaoServidor.configurado,
                    versaoApp = container.versaoApp,
                )
            }
        }
    }
}

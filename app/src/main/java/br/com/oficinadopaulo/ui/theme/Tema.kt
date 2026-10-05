package br.com.oficinadopaulo.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable

private val EsquemaClaro = lightColorScheme(
    primary = Paleta.LaranjaClaro,
    onPrimary = Paleta.Branco,
    primaryContainer = Paleta.LaranjaClaro.copy(alpha = 0.15f),
    onPrimaryContainer = Paleta.LaranjaPressionadoClaro,
    secondary = Paleta.Grafite,
    onSecondary = Paleta.Branco,
    background = Paleta.FundoClaro,
    onBackground = Paleta.TextoPrincipalClaro,
    surface = Paleta.SuperficieClaro,
    onSurface = Paleta.TextoPrincipalClaro,
    surfaceVariant = Paleta.FundoClaro,
    onSurfaceVariant = Paleta.TextoSecundarioClaro,
    surfaceContainer = Paleta.SuperficieClaro,
    error = Paleta.PendenteClaro,
    onError = Paleta.Branco,
)

private val EsquemaEscuro = darkColorScheme(
    primary = Paleta.LaranjaEscuro,
    onPrimary = Paleta.FundoEscuro,
    primaryContainer = Paleta.LaranjaEscuro.copy(alpha = 0.25f),
    onPrimaryContainer = Paleta.LaranjaEscuro,
    secondary = Paleta.Grafite,
    onSecondary = Paleta.TextoPrincipalEscuro,
    background = Paleta.FundoEscuro,
    onBackground = Paleta.TextoPrincipalEscuro,
    surface = Paleta.SuperficieEscuro,
    onSurface = Paleta.TextoPrincipalEscuro,
    surfaceVariant = Paleta.SuperficieEscuro,
    onSurfaceVariant = Paleta.TextoSecundarioEscuro,
    surfaceContainer = Paleta.SuperficieEscuro,
    error = Paleta.PendenteEscuro,
    onError = Paleta.FundoEscuro,
)

/** Tema do app. Sem cores dinâmicas: a identidade visual é sempre a da oficina. */
@Composable
fun OficinaTheme(
    temaEscuro: Boolean = isSystemInDarkTheme(),
    conteudo: @Composable () -> Unit,
) {
    CompositionLocalProvider(
        LocalCoresOficina provides if (temaEscuro) CoresOficinaEscuro else CoresOficinaClaro,
    ) {
        MaterialTheme(
            colorScheme = if (temaEscuro) EsquemaEscuro else EsquemaClaro,
            typography = TipografiaOficina,
            shapes = FormasOficina,
            content = conteudo,
        )
    }
}

/** Atalho: `OficinaTema.cores.pago` etc. */
object OficinaTema {
    val cores: CoresOficina
        @Composable @ReadOnlyComposable
        get() = LocalCoresOficina.current
}

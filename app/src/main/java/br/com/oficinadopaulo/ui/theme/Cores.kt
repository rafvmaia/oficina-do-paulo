package br.com.oficinadopaulo.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

// Paleta da identidade visual (agentes/CONTEXTO.md).
object Paleta {
    val LaranjaClaro = Color(0xFFE8630A)
    val LaranjaEscuro = Color(0xFFFF7A1F)
    val LaranjaPressionadoClaro = Color(0xFFB84D05)
    val LaranjaPressionadoEscuro = Color(0xFFE8630A)
    val Grafite = Color(0xFF1F2A36)

    val FundoClaro = Color(0xFFF4F5F7)
    val FundoEscuro = Color(0xFF121820)
    val SuperficieClaro = Color(0xFFFFFFFF)
    val SuperficieEscuro = Color(0xFF1F2A36)

    val TextoPrincipalClaro = Color(0xFF1A1A1A)
    val TextoSecundarioClaro = Color(0xFF5F6B7A)
    val TextoPrincipalEscuro = Color(0xFFECEFF3)
    val TextoSecundarioEscuro = Color(0xFFA9B4C2)

    val PagoClaro = Color(0xFF2E7D32)
    val PagoEscuro = Color(0xFF66BB6A)
    val ParcialClaro = Color(0xFFF9A825)
    val ParcialEscuro = Color(0xFFFFCA28)
    val PendenteClaro = Color(0xFFC62828)
    val PendenteEscuro = Color(0xFFEF5350)

    val Branco = Color(0xFFFFFFFF)
    val QuasePreto = Color(0xFF1A1A1A)
}

/** Cores do app que não existem no ColorScheme do Material 3. */
@Immutable
data class CoresOficina(
    val primariaPressionada: Color,
    val topBar: Color,
    val conteudoTopBar: Color,
    val textoSecundario: Color,
    val pago: Color,
    val conteudoPago: Color,
    val parcial: Color,
    val conteudoParcial: Color,
    val pendente: Color,
    val conteudoPendente: Color,
)

val CoresOficinaClaro = CoresOficina(
    primariaPressionada = Paleta.LaranjaPressionadoClaro,
    topBar = Paleta.Grafite,
    conteudoTopBar = Paleta.Branco,
    textoSecundario = Paleta.TextoSecundarioClaro,
    pago = Paleta.PagoClaro,
    conteudoPago = Paleta.Branco,
    parcial = Paleta.ParcialClaro,
    conteudoParcial = Paleta.QuasePreto,
    pendente = Paleta.PendenteClaro,
    conteudoPendente = Paleta.Branco,
)

val CoresOficinaEscuro = CoresOficina(
    primariaPressionada = Paleta.LaranjaPressionadoEscuro,
    topBar = Paleta.Grafite,
    conteudoTopBar = Paleta.TextoPrincipalEscuro,
    textoSecundario = Paleta.TextoSecundarioEscuro,
    pago = Paleta.PagoEscuro,
    conteudoPago = Paleta.FundoEscuro,
    parcial = Paleta.ParcialEscuro,
    conteudoParcial = Paleta.FundoEscuro,
    pendente = Paleta.PendenteEscuro,
    conteudoPendente = Paleta.FundoEscuro,
)

val LocalCoresOficina = staticCompositionLocalOf { CoresOficinaClaro }

package br.com.oficinadopaulo.ui.navegacao

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.People
import androidx.compose.ui.graphics.vector.ImageVector

/** Abas da barra inferior. */
enum class Aba(val rota: String, val titulo: String, val icone: ImageVector, val tag: String) {
    INICIO("inicio", "Início", Icons.Filled.Home, "aba_inicio"),
    CLIENTES("clientes", "Clientes", Icons.Filled.People, "aba_clientes"),
    A_RECEBER("a_receber", "A Receber", Icons.Filled.Payments, "aba_a_receber"),
    SERVICOS("servicos", "Serviços", Icons.Filled.Build, "aba_servicos"),
}

object Rotas {
    const val CONFIGURACOES = "configuracoes"
}

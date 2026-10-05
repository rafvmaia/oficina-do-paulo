package br.com.oficinadopaulo.ui.telas

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.People
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import br.com.oficinadopaulo.ui.components.EstadoVazio

object TextosVazios {
    const val INICIO = "Nenhum serviço registrado ainda.\nAqui vai aparecer o resumo da oficina: serviços em andamento e valores a receber."
    const val CLIENTES = "Nenhum cliente cadastrado ainda."
    const val A_RECEBER = "Nenhum valor a receber.\nTodos os serviços estão pagos."
    const val SERVICOS = "Nenhum serviço cadastrado ainda."
}

@Composable
fun TelaInicio() {
    EstadoVazio(Icons.Filled.Home, TextosVazios.INICIO, Modifier.testTag("tela_inicio"))
}

@Composable
fun TelaClientes() {
    EstadoVazio(Icons.Filled.People, TextosVazios.CLIENTES, Modifier.testTag("tela_clientes"))
}

@Composable
fun TelaAReceber() {
    EstadoVazio(Icons.Filled.Payments, TextosVazios.A_RECEBER, Modifier.testTag("tela_a_receber"))
}

@Composable
fun TelaServicos() {
    EstadoVazio(Icons.Filled.Build, TextosVazios.SERVICOS, Modifier.testTag("tela_servicos"))
}

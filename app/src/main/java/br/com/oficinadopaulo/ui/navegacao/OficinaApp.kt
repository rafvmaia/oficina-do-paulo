package br.com.oficinadopaulo.ui.navegacao

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import br.com.oficinadopaulo.ui.telas.TelaAReceber
import br.com.oficinadopaulo.ui.telas.TelaAbertura
import br.com.oficinadopaulo.ui.telas.TelaClientes
import br.com.oficinadopaulo.ui.telas.TelaConfiguracoes
import br.com.oficinadopaulo.ui.telas.TelaInicio
import br.com.oficinadopaulo.ui.telas.TelaServicos
import br.com.oficinadopaulo.ui.theme.OficinaTema
import kotlinx.coroutines.delay

/** Tempo que a abertura "Oficina do Paulo" fica na tela ao iniciar o app. */
const val DURACAO_ABERTURA_MS = 900L

/** Raiz da interface: abertura, top bar, barra inferior com as 4 abas e Configurações. */
@Composable
fun OficinaApp(
    servidorConfigurado: Boolean,
    versaoApp: String,
    mostrarAbertura: Boolean = true,
    navController: NavHostController = rememberNavController(),
) {
    var exibindoAbertura by rememberSaveable { mutableStateOf(mostrarAbertura) }
    if (exibindoAbertura) {
        LaunchedEffect(Unit) {
            delay(DURACAO_ABERTURA_MS)
            exibindoAbertura = false
        }
        TelaAbertura()
        return
    }

    val entradaAtual by navController.currentBackStackEntryAsState()
    val destinoAtual = entradaAtual?.destination
    val rotaAtual = destinoAtual?.route
    val abaAtual = Aba.entries.firstOrNull { aba -> destinoAtual?.hierarchy?.any { it.route == aba.rota } == true }
    val emConfiguracoes = rotaAtual == Rotas.CONFIGURACOES

    Scaffold(
        topBar = {
            BarraSuperior(
                titulo = if (emConfiguracoes) "Configurações" else (abaAtual ?: Aba.INICIO).titulo,
                emConfiguracoes = emConfiguracoes,
                onConfiguracoes = { navController.navigate(Rotas.CONFIGURACOES) { launchSingleTop = true } },
                onVoltar = { navController.popBackStack() },
            )
        },
        bottomBar = {
            if (!emConfiguracoes) {
                BarraInferior(
                    abaAtual = abaAtual ?: Aba.INICIO,
                    onSelecionar = { aba ->
                        navController.navigate(aba.rota) {
                            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                )
            }
        },
    ) { espacamento ->
        NavHost(
            navController = navController,
            startDestination = Aba.INICIO.rota,
            modifier = Modifier.padding(espacamento),
        ) {
            composable(Aba.INICIO.rota) { TelaInicio() }
            composable(Aba.CLIENTES.rota) { TelaClientes() }
            composable(Aba.A_RECEBER.rota) { TelaAReceber() }
            composable(Aba.SERVICOS.rota) { TelaServicos() }
            composable(Rotas.CONFIGURACOES) {
                TelaConfiguracoes(servidorConfigurado = servidorConfigurado, versaoApp = versaoApp)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun BarraSuperior(
    titulo: String,
    emConfiguracoes: Boolean,
    onConfiguracoes: () -> Unit,
    onVoltar: () -> Unit,
) {
    val cores = OficinaTema.cores
    TopAppBar(
        title = { Text(titulo, modifier = Modifier.testTag("titulo_tela")) },
        navigationIcon = {
            if (emConfiguracoes) {
                IconButton(onClick = onVoltar, modifier = Modifier.testTag("btn_voltar")) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Voltar")
                }
            }
        },
        actions = {
            if (!emConfiguracoes) {
                IconButton(onClick = onConfiguracoes, modifier = Modifier.testTag("btn_configuracoes")) {
                    Icon(Icons.Filled.Settings, contentDescription = "Configurações")
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = cores.topBar,
            titleContentColor = cores.conteudoTopBar,
            navigationIconContentColor = cores.conteudoTopBar,
            actionIconContentColor = cores.conteudoTopBar,
        ),
    )
}

@Composable
private fun BarraInferior(abaAtual: Aba, onSelecionar: (Aba) -> Unit) {
    NavigationBar(containerColor = MaterialTheme.colorScheme.surface) {
        Aba.entries.forEach { aba ->
            NavigationBarItem(
                selected = aba == abaAtual,
                onClick = { onSelecionar(aba) },
                icon = { Icon(aba.icone, contentDescription = null) },
                label = { Text(aba.titulo) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = MaterialTheme.colorScheme.primary,
                    selectedTextColor = MaterialTheme.colorScheme.primary,
                    indicatorColor = MaterialTheme.colorScheme.primaryContainer,
                ),
                modifier = Modifier.testTag(aba.tag),
            )
        }
    }
}

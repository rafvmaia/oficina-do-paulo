package br.com.oficinadopaulo

import android.content.Context
import br.com.oficinadopaulo.data.ConfiguracaoServidor

/** Injeção de dependências manual: um único container por processo, criado no Application. */
class AppContainer(
    @Suppress("unused") private val contexto: Context,
) {
    val configuracaoServidor = ConfiguracaoServidor(
        url = BuildConfig.SUPABASE_URL,
        chaveAnonima = BuildConfig.SUPABASE_ANON_KEY,
    )
    val versaoApp: String = BuildConfig.VERSION_NAME
}

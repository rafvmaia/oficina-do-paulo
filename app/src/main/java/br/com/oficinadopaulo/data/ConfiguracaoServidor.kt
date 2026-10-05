package br.com.oficinadopaulo.data

/** Endereço e chave pública do Supabase (vindos do BuildConfig; podem estar vazios). */
data class ConfiguracaoServidor(
    val url: String,
    val chaveAnonima: String,
) {
    val configurado: Boolean get() = url.isNotBlank() && chaveAnonima.isNotBlank()
}

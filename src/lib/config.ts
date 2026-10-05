/**
 * Configuração vinda de variáveis de ambiente (inseridas no bundle pelo Expo
 * a partir de EXPO_PUBLIC_*). Nada de segredo no código.
 */
export interface ConfigSupabase {
  url: string;
  anonKey: string;
}

export function lerConfigSupabase(
  env: Record<string, string | undefined> = {
    EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
    EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
  },
): ConfigSupabase | null {
  const url = env.EXPO_PUBLIC_SUPABASE_URL?.trim() ?? '';
  const anonKey = env.EXPO_PUBLIC_SUPABASE_ANON_KEY?.trim() ?? '';
  if (!url || !anonKey) return null;
  return { url, anonKey };
}

export const configSupabase = lerConfigSupabase();
export const supabaseConfigurado = configSupabase !== null;

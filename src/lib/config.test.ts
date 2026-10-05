import { lerConfigSupabase } from './config';

describe('lerConfigSupabase', () => {
  it('sem variáveis → null (app mostra "Servidor não configurado")', () => {
    expect(lerConfigSupabase({})).toBeNull();
  });

  it('variáveis vazias ou só com espaços → null', () => {
    expect(
      lerConfigSupabase({ EXPO_PUBLIC_SUPABASE_URL: ' ', EXPO_PUBLIC_SUPABASE_ANON_KEY: '' }),
    ).toBeNull();
  });

  it('só uma das variáveis → null', () => {
    expect(lerConfigSupabase({ EXPO_PUBLIC_SUPABASE_URL: 'https://x.supabase.co' })).toBeNull();
  });

  it('com as duas → config', () => {
    expect(
      lerConfigSupabase({
        EXPO_PUBLIC_SUPABASE_URL: ' https://x.supabase.co ',
        EXPO_PUBLIC_SUPABASE_ANON_KEY: 'chave-publica',
      }),
    ).toEqual({ url: 'https://x.supabase.co', anonKey: 'chave-publica' });
  });
});

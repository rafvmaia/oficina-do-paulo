import { MD3DarkTheme, MD3LightTheme, type MD3Theme } from 'react-native-paper';

import { coresClaro, coresEscuro, type PaletaApp } from './cores';

export type EsquemaCor = 'claro' | 'escuro';

export type TemaApp = MD3Theme & {
  esquema: EsquemaCor;
  app: PaletaApp;
};

function criarTema(esquema: EsquemaCor): TemaApp {
  const base = esquema === 'escuro' ? MD3DarkTheme : MD3LightTheme;
  const c = esquema === 'escuro' ? coresEscuro : coresClaro;
  return {
    ...base,
    esquema,
    app: c,
    colors: {
      ...base.colors,
      primary: c.primaria,
      onPrimary: esquema === 'escuro' ? '#121820' : '#FFFFFF',
      primaryContainer: c.primariaPressionada,
      onPrimaryContainer: '#FFFFFF',
      secondary: c.grafite,
      onSecondary: '#FFFFFF',
      background: c.fundo,
      onBackground: c.texto,
      surface: c.superficie,
      onSurface: c.texto,
      surfaceVariant: c.superficie,
      onSurfaceVariant: c.textoSecundario,
      error: c.pendente,
      outline: c.textoSecundario,
      elevation: {
        ...base.colors.elevation,
        level2: c.superficie,
      },
    },
  };
}

export const temaClaro = criarTema('claro');
export const temaEscuro = criarTema('escuro');

/** Converte o retorno de `useColorScheme()` no tema do app (padrão: claro). */
export function temaParaEsquema(esquemaSistema: string | null | undefined): TemaApp {
  return esquemaSistema === 'dark' ? temaEscuro : temaClaro;
}

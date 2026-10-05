import type { ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import { PaperProvider, useTheme } from 'react-native-paper';

import { temaParaEsquema, type TemaApp } from './tema';

export { coresClaro, coresEscuro, type PaletaApp } from './cores';
export { temaClaro, temaEscuro, temaParaEsquema, type TemaApp, type EsquemaCor } from './tema';

/** Tema atual do app (Paper MD3 + paleta própria). */
export const useTemaApp = () => useTheme<TemaApp>();

/** Hook que segue o modo claro/escuro do sistema. */
export function useTemaDoSistema(): TemaApp {
  return temaParaEsquema(useColorScheme());
}

/** Provedor de tema. Sem `tema`, segue o modo do sistema. */
export function ProvedorTema({ tema, children }: { tema?: TemaApp; children: ReactNode }) {
  const doSistema = useTemaDoSistema();
  return <PaperProvider theme={tema ?? doSistema}>{children}</PaperProvider>;
}

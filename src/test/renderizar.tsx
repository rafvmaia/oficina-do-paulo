import { render } from '@testing-library/react-native';
import type { ReactElement } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { ProvedorTema, temaClaro, type TemaApp } from '@/theme';

const metricas = {
  frame: { x: 0, y: 0, width: 390, height: 844 },
  insets: { top: 0, left: 0, right: 0, bottom: 0 },
};

/** Renderiza com SafeArea + tema Paper do app (claro por padrão). */
export function renderizar(ui: ReactElement, tema: TemaApp = temaClaro) {
  return render(
    <SafeAreaProvider initialMetrics={metricas}>
      <ProvedorTema tema={tema}>{ui}</ProvedorTema>
    </SafeAreaProvider>,
  );
}

import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import type { ComponentProps } from 'react';
import { StyleSheet, View } from 'react-native';
import { Text } from 'react-native-paper';

import type { StatusPagamento } from '@/domain/statusPagamento';
import { useTemaApp, type PaletaApp } from '@/theme';

type NomeIcone = ComponentProps<typeof MaterialCommunityIcons>['name'];

interface Visual {
  icone: NomeIcone;
  texto: string;
  fundo: keyof PaletaApp;
  frente: keyof PaletaApp;
}

/** ✓ PAGO / ◐ PARCIAL / ! PENDENTE — sempre cor + ícone + texto. */
export const VISUAL_STATUS: Record<StatusPagamento, Visual> = {
  PAGO: { icone: 'check-circle', texto: 'PAGO', fundo: 'pago', frente: 'sobrePago' },
  PARCIAL: {
    icone: 'circle-half-full',
    texto: 'PARCIAL',
    fundo: 'parcial',
    frente: 'sobreParcial',
  },
  PENDENTE: {
    icone: 'alert-circle',
    texto: 'PENDENTE',
    fundo: 'pendente',
    frente: 'sobrePendente',
  },
};

export interface StatusPagamentoChipProps {
  status: StatusPagamento;
  testID?: string;
}

export function StatusPagamentoChip({
  status,
  testID = 'chip-status-pagamento',
}: StatusPagamentoChipProps) {
  const tema = useTemaApp();
  const visual = VISUAL_STATUS[status];
  const fundo = tema.app[visual.fundo];
  const frente = tema.app[visual.frente];

  return (
    <View
      testID={testID}
      accessible
      accessibilityRole="text"
      accessibilityLabel={`Status de pagamento: ${visual.texto}`}
      style={[styles.chip, { backgroundColor: fundo }]}
    >
      <MaterialCommunityIcons
        testID={`${testID}-icone`}
        name={visual.icone}
        size={18}
        color={frente}
      />
      <Text testID={`${testID}-texto`} style={[styles.texto, { color: frente }]}>
        {visual.texto}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    gap: 6,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    minHeight: 32,
  },
  texto: {
    fontWeight: '700',
    fontSize: 14,
    letterSpacing: 0.5,
  },
});

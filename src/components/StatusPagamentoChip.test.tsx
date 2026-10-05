import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import { screen } from '@testing-library/react-native';
import { StyleSheet } from 'react-native';

import { StatusPagamentoChip } from './StatusPagamentoChip';

import type { StatusPagamento } from '@/domain/statusPagamento';
import { renderizar } from '@/test/renderizar';
import { temaClaro, temaEscuro, type TemaApp } from '@/theme';

function glifo(nome: keyof typeof MaterialCommunityIcons.glyphMap): string {
  return String.fromCodePoint(MaterialCommunityIcons.glyphMap[nome] as number);
}

const casos: {
  status: StatusPagamento;
  texto: string;
  icone: keyof typeof MaterialCommunityIcons.glyphMap;
  claro: string;
  escuro: string;
}[] = [
  { status: 'PAGO', texto: 'PAGO', icone: 'check-circle', claro: '#2E7D32', escuro: '#66BB6A' },
  {
    status: 'PARCIAL',
    texto: 'PARCIAL',
    icone: 'circle-half-full',
    claro: '#F9A825',
    escuro: '#FFCA28',
  },
  {
    status: 'PENDENTE',
    texto: 'PENDENTE',
    icone: 'alert-circle',
    claro: '#C62828',
    escuro: '#EF5350',
  },
];

describe.each<[string, TemaApp, 'claro' | 'escuro']>([
  ['tema claro', temaClaro, 'claro'],
  ['tema escuro', temaEscuro, 'escuro'],
])('StatusPagamentoChip (%s)', (_nome, tema, chave) => {
  it.each(casos)('$status: cor + ícone + texto', async (caso) => {
    await renderizar(<StatusPagamentoChip status={caso.status} />, tema);

    const chip = screen.getByTestId('chip-status-pagamento');
    expect(StyleSheet.flatten(chip.props.style).backgroundColor).toBe(caso[chave]);
    expect(chip).toHaveAccessibleName(`Status de pagamento: ${caso.texto}`);

    expect(screen.getByTestId('chip-status-pagamento-texto')).toHaveTextContent(caso.texto);
    expect(screen.getByTestId('chip-status-pagamento-icone')).toHaveTextContent(glifo(caso.icone));

    // o texto e o ícone usam a mesma cor de contraste
    const corTexto = StyleSheet.flatten(
      screen.getByTestId('chip-status-pagamento-texto').props.style,
    ).color;
    const corIcone = StyleSheet.flatten(
      screen.getByTestId('chip-status-pagamento-icone').props.style,
    ).color;
    expect(corTexto).toBe(corIcone);
    expect(corTexto).not.toBe(caso[chave]);
  });
});

it('aceita testID personalizado', async () => {
  await renderizar(<StatusPagamentoChip status="PAGO" testID="chip-servico-1" />);
  expect(screen.getByTestId('chip-servico-1')).toBeOnTheScreen();
  expect(screen.queryByTestId('chip-status-pagamento')).toBeNull();
});

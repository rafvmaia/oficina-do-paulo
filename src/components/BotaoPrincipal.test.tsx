import { fireEvent, screen } from '@testing-library/react-native';
import { StyleSheet } from 'react-native';

import { ALTURA_BOTAO_PRINCIPAL, BotaoPrincipal } from './BotaoPrincipal';

import { renderizar } from '@/test/renderizar';
import { temaEscuro } from '@/theme';

describe('BotaoPrincipal', () => {
  it('mostra o texto, tem 56dp e chama onPress', async () => {
    const onPress = jest.fn();
    await renderizar(<BotaoPrincipal texto="Salvar" onPress={onPress} />);

    expect(screen.getByText('Salvar')).toBeOnTheScreen();
    expect(ALTURA_BOTAO_PRINCIPAL).toBe(56);
    // o primeiro filho do botão é a área de conteúdo do Paper (onde fica a altura)
    const conteudo = screen.getByTestId('botao-principal').children[0];
    expect(typeof conteudo).not.toBe('string');
    if (typeof conteudo !== 'string') {
      expect(StyleSheet.flatten(conteudo.props.style).height).toBeGreaterThanOrEqual(56);
    }

    await fireEvent.press(screen.getByRole('button', { name: 'Salvar' }));
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('desabilitado não dispara onPress', async () => {
    const onPress = jest.fn();
    await renderizar(<BotaoPrincipal texto="Salvar" onPress={onPress} desabilitado />);
    const botao = screen.getByRole('button', { name: 'Salvar' });
    expect(botao).toBeDisabled();
    await fireEvent.press(botao);
    expect(onPress).not.toHaveBeenCalled();
  });

  it('carregando fica desabilitado', async () => {
    const onPress = jest.fn();
    await renderizar(<BotaoPrincipal texto="Salvar" onPress={onPress} carregando />);
    expect(screen.getByRole('button', { name: 'Salvar' })).toBeDisabled();
  });

  it('usa accessibilityLabel personalizado e renderiza no tema escuro', async () => {
    await renderizar(
      <BotaoPrincipal texto="Pagar" accessibilityLabel="Registrar pagamento" onPress={jest.fn()} />,
      temaEscuro,
    );
    expect(screen.getByRole('button', { name: 'Registrar pagamento' })).toBeOnTheScreen();
  });
});

import { fireEvent, screen } from '@testing-library/react-native';
import { StyleSheet } from 'react-native';

import { DialogoConfirmacao } from './DialogoConfirmacao';

import { renderizar } from '@/test/renderizar';
import { temaEscuro } from '@/theme';

describe('DialogoConfirmacao', () => {
  it('visível mostra título e mensagem; Confirmar e Cancelar chamam callbacks', async () => {
    const onConfirmar = jest.fn();
    const onCancelar = jest.fn();
    await renderizar(
      <DialogoConfirmacao
        visivel
        titulo="Excluir cliente?"
        mensagem="Os veículos, serviços e pagamentos dele também serão excluídos."
        textoConfirmar="Excluir"
        destrutivo
        onConfirmar={onConfirmar}
        onCancelar={onCancelar}
      />,
    );

    expect(screen.getByText('Excluir cliente?')).toBeOnTheScreen();
    expect(
      screen.getByText('Os veículos, serviços e pagamentos dele também serão excluídos.'),
    ).toBeOnTheScreen();

    await fireEvent.press(screen.getByRole('button', { name: 'Excluir' }));
    expect(onConfirmar).toHaveBeenCalledTimes(1);

    await fireEvent.press(screen.getByRole('button', { name: 'Cancelar' }));
    expect(onCancelar).toHaveBeenCalledTimes(1);
  });

  it('botão destrutivo usa a cor de PENDENTE e área de toque ≥ 48dp', async () => {
    await renderizar(
      <DialogoConfirmacao
        visivel
        titulo="Excluir?"
        mensagem="Não dá para desfazer."
        destrutivo
        onConfirmar={jest.fn()}
        onCancelar={jest.fn()}
      />,
      temaEscuro,
    );
    const confirmar = screen.getByTestId('dialogo-confirmacao-confirmar-container');
    expect(StyleSheet.flatten(confirmar.props.style).backgroundColor).toBe('#EF5350');
    const conteudo = screen.getByTestId('dialogo-confirmacao-confirmar').children[0];
    expect(typeof conteudo).not.toBe('string');
    if (typeof conteudo !== 'string') {
      expect(StyleSheet.flatten(conteudo.props.style).minHeight).toBeGreaterThanOrEqual(48);
    }
  });

  it('invisível não renderiza nada', async () => {
    await renderizar(
      <DialogoConfirmacao
        visivel={false}
        titulo="Excluir?"
        mensagem="Mensagem"
        onConfirmar={jest.fn()}
        onCancelar={jest.fn()}
      />,
    );
    expect(screen.queryByText('Excluir?')).toBeNull();
  });
});

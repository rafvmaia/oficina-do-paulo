import { fireEvent, screen } from '@testing-library/react-native';

import { CampoTexto } from './CampoTexto';

import { renderizar } from '@/test/renderizar';
import { temaEscuro } from '@/theme';

describe('CampoTexto', () => {
  it('mostra o rótulo e repassa o texto digitado', async () => {
    const onChangeText = jest.fn();
    await renderizar(<CampoTexto rotulo="Nome" value="" onChangeText={onChangeText} />);

    const campo = screen.getByTestId('campo-texto');
    expect(screen.getAllByText('Nome').length).toBeGreaterThan(0);
    await fireEvent.changeText(campo, 'Paulo');
    expect(onChangeText).toHaveBeenCalledWith('Paulo');
  });

  it('sem erro não mostra mensagem', async () => {
    await renderizar(<CampoTexto rotulo="Telefone" value="" onChangeText={jest.fn()} />);
    expect(screen.queryByTestId('campo-texto-erro')).toBeNull();
  });

  it('com erro mostra a mensagem abaixo do campo', async () => {
    await renderizar(
      <CampoTexto
        rotulo="Telefone"
        value=""
        onChangeText={jest.fn()}
        erro="Informe o telefone"
        testID="campo-telefone"
      />,
      temaEscuro,
    );
    expect(screen.getByTestId('campo-telefone-erro')).toHaveTextContent('Informe o telefone');
  });

  it('erro vazio ou nulo não mostra mensagem', async () => {
    await renderizar(<CampoTexto rotulo="Placa" value="" onChangeText={jest.fn()} erro={null} />);
    expect(screen.queryByTestId('campo-texto-erro')).toBeNull();
  });
});

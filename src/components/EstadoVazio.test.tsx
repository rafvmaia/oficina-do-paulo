import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import { screen } from '@testing-library/react-native';

import { BotaoPrincipal } from './BotaoPrincipal';
import { EstadoVazio } from './EstadoVazio';

import { renderizar } from '@/test/renderizar';
import { temaEscuro } from '@/theme';

describe('EstadoVazio', () => {
  it('mostra ícone e texto', async () => {
    await renderizar(<EstadoVazio icone="account-group" texto="Nenhum cliente cadastrado" />);
    expect(screen.getByText('Nenhum cliente cadastrado')).toBeOnTheScreen();
    expect(screen.getByTestId('estado-vazio-icone')).toHaveTextContent(
      String.fromCodePoint(MaterialCommunityIcons.glyphMap['account-group'] as number),
    );
  });

  it('mostra detalhe e ação quando informados (tema escuro)', async () => {
    const onPress = jest.fn();
    await renderizar(
      <EstadoVazio
        icone="wrench"
        texto="Nenhum serviço"
        detalhe="Cadastre o primeiro serviço"
        acao={<BotaoPrincipal texto="Novo serviço" onPress={onPress} />}
        testID="vazio-servicos"
      />,
      temaEscuro,
    );
    expect(screen.getByTestId('vazio-servicos')).toBeOnTheScreen();
    expect(screen.getByText('Cadastre o primeiro serviço')).toBeOnTheScreen();
    expect(screen.getByRole('button', { name: 'Novo serviço' })).toBeOnTheScreen();
  });

  it('sem detalhe não renderiza texto extra', async () => {
    await renderizar(<EstadoVazio icone="cash" texto="Nada a receber" />);
    expect(screen.queryByText('Cadastre o primeiro serviço')).toBeNull();
  });
});

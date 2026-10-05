import { fireEvent, screen } from '@testing-library/react-native';
import { renderRouter } from 'expo-router/testing-library';
import { useColorScheme } from 'react-native';

jest.mock('react-native/Libraries/Utilities/useColorScheme', () => ({
  __esModule: true,
  default: jest.fn(() => 'light'),
}));

// O estado do servidor não pode depender das variáveis de ambiente da máquina/CI.
const mockConfig = { supabaseConfigurado: false };
jest.mock('@/lib/config', () => ({
  get supabaseConfigurado() {
    return mockConfig.supabaseConfigurado;
  },
}));

const mockEsquema = useColorScheme as jest.MockedFunction<typeof useColorScheme>;

const ABAS = [
  { id: 'aba-index', titulo: 'Início', tela: 'tela-inicio' },
  { id: 'aba-clientes', titulo: 'Clientes', tela: 'tela-clientes' },
  { id: 'aba-a-receber', titulo: 'A Receber', tela: 'tela-a-receber' },
  { id: 'aba-servicos', titulo: 'Serviços', tela: 'tela-servicos' },
];

/**
 * Com o RNTL v14 o `render` é assíncrono: `renderRouter` devolve a Promise do
 * render com os utilitários de rota (getPathname etc.) anexados a ela.
 */
async function abrirApp(url = '/') {
  const app = renderRouter('./app', { initialUrl: url });
  await app;
  return { pathname: () => app.getPathname() };
}

describe('navegação principal', () => {
  beforeEach(() => {
    mockEsquema.mockReturnValue('light');
    mockConfig.supabaseConfigurado = false;
  });

  it('renderiza as 4 abas', async () => {
    await abrirApp();
    for (const aba of ABAS) {
      expect(screen.getByTestId(aba.id)).toBeOnTheScreen();
      expect(screen.getByRole('button', { name: aba.titulo })).toBeOnTheScreen();
    }
    expect(screen.getByTestId('tela-inicio')).toBeOnTheScreen();
  });

  it.each(ABAS)('tocar em "$titulo" mostra o título e a tela correta', async (aba) => {
    const app = await abrirApp();
    await fireEvent.press(screen.getByTestId(aba.id));
    expect(screen.getByTestId(aba.tela)).toBeOnTheScreen();
    // título no cabeçalho + rótulo da aba
    expect(screen.getAllByText(aba.titulo).length).toBeGreaterThanOrEqual(2);
    expect(app.pathname()).toBe(aba.id === 'aba-index' ? '/' : `/${aba.id.slice(4)}`);
  });

  it('telas têm estado vazio real (sem "em construção")', async () => {
    await abrirApp('/clientes');
    expect(screen.getByText('Nenhum cliente cadastrado')).toBeOnTheScreen();
    expect(screen.queryByText(/constru/i)).toBeNull();
  });

  it('botão Configurações no cabeçalho abre a tela de Configurações', async () => {
    const app = await abrirApp();
    await fireEvent.press(screen.getByRole('button', { name: 'Configurações' }));
    expect(app.pathname()).toBe('/configuracoes');
    expect(screen.getByTestId('tela-configuracoes')).toBeOnTheScreen();
    expect(screen.getByText('Servidor não configurado')).toBeOnTheScreen();
  });

  it('Configurações mostra servidor configurado quando há variáveis do Supabase', async () => {
    mockConfig.supabaseConfigurado = true;
    await abrirApp('/configuracoes');
    expect(screen.getByText('Configurado')).toBeOnTheScreen();
    expect(screen.queryByText('Servidor não configurado')).toBeNull();
  });

  it('renderiza no tema escuro com fundo escuro', async () => {
    mockEsquema.mockReturnValue('dark');
    await abrirApp('/servicos');
    expect(screen.getByTestId('tela-servicos')).toBeOnTheScreen();
    expect(screen.getByText('Nenhum serviço registrado')).toHaveStyle({ color: '#ECEFF3' });
  });

  it('no tema claro o texto usa a cor clara do CONTEXTO', async () => {
    await abrirApp('/a-receber');
    expect(screen.getByText('Nada a receber')).toHaveStyle({ color: '#1A1A1A' });
  });
});

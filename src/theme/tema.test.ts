import { coresClaro, coresEscuro } from './cores';
import { temaClaro, temaEscuro, temaParaEsquema } from './tema';

describe('paleta (CONTEXTO.md)', () => {
  it('modo claro', () => {
    expect(coresClaro).toMatchObject({
      primaria: '#E8630A',
      primariaPressionada: '#B84D05',
      grafite: '#1F2A36',
      fundo: '#F4F5F7',
      superficie: '#FFFFFF',
      texto: '#1A1A1A',
      textoSecundario: '#5F6B7A',
      pago: '#2E7D32',
      parcial: '#F9A825',
      pendente: '#C62828',
    });
  });

  it('modo escuro', () => {
    expect(coresEscuro).toMatchObject({
      primaria: '#FF7A1F',
      primariaPressionada: '#E8630A',
      grafite: '#1F2A36',
      fundo: '#121820',
      superficie: '#1F2A36',
      texto: '#ECEFF3',
      textoSecundario: '#A9B4C2',
      pago: '#66BB6A',
      parcial: '#FFCA28',
      pendente: '#EF5350',
    });
  });
});

describe('tema Paper MD3', () => {
  it('claro usa as cores do app', () => {
    expect(temaClaro.dark).toBe(false);
    expect(temaClaro.version).toBe(3);
    expect(temaClaro.colors.primary).toBe('#E8630A');
    expect(temaClaro.colors.background).toBe('#F4F5F7');
    expect(temaClaro.colors.surface).toBe('#FFFFFF');
    expect(temaClaro.colors.error).toBe('#C62828');
  });

  it('escuro usa as cores do app', () => {
    expect(temaEscuro.dark).toBe(true);
    expect(temaEscuro.colors.primary).toBe('#FF7A1F');
    expect(temaEscuro.colors.background).toBe('#121820');
    expect(temaEscuro.colors.surface).toBe('#1F2A36');
    expect(temaEscuro.app.pago).toBe('#66BB6A');
  });

  it.each([
    ['dark', temaEscuro],
    ['light', temaClaro],
    [null, temaClaro],
    [undefined, temaClaro],
    ['unspecified', temaClaro],
  ])('esquema do sistema %p → tema correspondente', (esquema, esperado) => {
    expect(temaParaEsquema(esquema)).toBe(esperado);
  });
});

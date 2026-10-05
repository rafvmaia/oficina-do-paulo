import { formatarCentavos, parseValor } from './dinheiro';

describe('formatarCentavos', () => {
  it.each([
    [0, 'R$ 0,00'],
    [5, 'R$ 0,05'],
    [100, 'R$ 1,00'],
    [123456, 'R$ 1.234,56'],
    [100000000, 'R$ 1.000.000,00'],
    [-1550, '-R$ 15,50'],
    [-5, '-R$ 0,05'],
    [99999, 'R$ 999,99'],
  ])('%p → %p', (centavos, esperado) => {
    expect(formatarCentavos(centavos)).toBe(esperado);
  });

  it.each([12.5, NaN, Infinity, -Infinity])('rejeita valor não inteiro %p', (valor) => {
    expect(() => formatarCentavos(valor)).toThrow(RangeError);
  });
});

describe('parseValor', () => {
  it.each([
    ['12,50', 1250],
    ['1.234,56', 123456],
    ['R$ 10', 1000],
    ['R$1.234,5', 123450],
    ['12,5', 1250],
    ['0,99', 99],
    ['0', 0],
    ['1234', 123400],
    ['1.000', 100000],
    ['12.50', 1250],
    ['  7,00  ', 700],
    ['r$ 3', 300],
    ['1.000.000,00', 100000000],
  ])('%p → %p', (texto, esperado) => {
    expect(parseValor(texto)).toBe(esperado);
  });

  it.each([
    '',
    '   ',
    'abc',
    '12,555',
    '-10',
    '-10,00',
    '1.23,00',
    '12,50,00',
    '12,',
    ',50',
    '1.2.3',
    '10 reais',
    'R$',
  ])('retorna null para %p', (texto) => {
    expect(parseValor(texto)).toBeNull();
  });

  it('faz ida e volta com formatarCentavos', () => {
    for (const n of [0, 1, 99, 100, 1050, 123456, 100000000]) {
      expect(parseValor(formatarCentavos(n))).toBe(n);
    }
  });
});

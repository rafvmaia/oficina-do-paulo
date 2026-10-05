/**
 * Dinheiro é SEMPRE representado em centavos inteiros.
 * Exibição no padrão brasileiro: `R$ 1.234,56`.
 */

function agruparMilhares(inteiro: string): string {
  return inteiro.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

/** Formata centavos inteiros como `R$ 1.234,56` (negativos: `-R$ 15,50`). */
export function formatarCentavos(centavos: number): string {
  if (!Number.isSafeInteger(centavos)) {
    throw new RangeError(`Valor em centavos inválido: ${centavos}`);
  }
  const negativo = centavos < 0;
  const absoluto = Math.abs(centavos);
  const reais = Math.floor(absoluto / 100);
  const resto = absoluto % 100;
  const texto = `R$ ${agruparMilhares(String(reais))},${String(resto).padStart(2, '0')}`;
  return negativo ? `-${texto}` : texto;
}

const COM_VIRGULA = /^(\d{1,3}(?:\.\d{3})+|\d+),(\d{1,2})$/;
const SO_INTEIRO = /^(\d{1,3}(?:\.\d{3})+|\d+)$/;
const PONTO_DECIMAL = /^(\d+)\.(\d{1,2})$/;

/**
 * Converte o texto digitado pelo usuário em centavos inteiros.
 * Aceita `12,50`, `1.234,56`, `R$ 10`, `12.50`. Retorna `null` se inválido,
 * vazio, negativo ou com mais de 2 casas decimais.
 */
export function parseValor(texto: string): number | null {
  const limpo = texto.replace(/R\$/i, '').replace(/\s+/g, '');
  if (limpo === '') return null;

  let inteiro: string;
  let decimal = '';

  const comVirgula = COM_VIRGULA.exec(limpo);
  const soInteiro = SO_INTEIRO.exec(limpo);
  const pontoDecimal = PONTO_DECIMAL.exec(limpo);
  if (comVirgula) {
    inteiro = comVirgula[1];
    decimal = comVirgula[2];
  } else if (soInteiro) {
    inteiro = soInteiro[1];
  } else if (pontoDecimal) {
    inteiro = pontoDecimal[1];
    decimal = pontoDecimal[2];
  } else {
    return null;
  }

  const reais = Number(inteiro.replace(/\./g, ''));
  const centavos = Number(decimal.padEnd(2, '0'));
  const total = reais * 100 + centavos;
  return Number.isSafeInteger(total) ? total : null;
}

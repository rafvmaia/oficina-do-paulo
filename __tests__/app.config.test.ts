import type { ConfigContext } from 'expo/config';

import criarConfig, { lerVersao, lerVersionCode } from '../app.config';

const contexto = { config: {} } as ConfigContext;

describe('app.config.ts', () => {
  const envOriginal = { ...process.env };
  afterEach(() => {
    process.env = { ...envOriginal };
  });

  it('identidade do app', () => {
    const config = criarConfig(contexto);
    expect(config.name).toBe('Oficina do Paulo');
    expect(config.slug).toBe('oficina-do-paulo');
    expect(config.android?.package).toBe('br.com.oficinadopaulo');
    expect(config.userInterfaceStyle).toBe('automatic');
    expect(config.android?.adaptiveIcon?.backgroundColor).toBe('#1F2A36');
    expect(config.plugins).toContain('./plugins/withAndroidSigning');
  });

  it('padrões sem variáveis de ambiente', () => {
    delete process.env.APP_VERSION;
    delete process.env.APP_VERSION_CODE;
    const config = criarConfig(contexto);
    expect(config.version).toBe('1.0.0');
    expect(config.android?.versionCode).toBe(1);
  });

  it('lê APP_VERSION e APP_VERSION_CODE', () => {
    process.env.APP_VERSION = 'v2.3.4';
    process.env.APP_VERSION_CODE = '57';
    const config = criarConfig(contexto);
    expect(config.version).toBe('2.3.4');
    expect(config.android?.versionCode).toBe(57);
  });

  it.each([
    [undefined, '1.0.0'],
    ['', '1.0.0'],
    ['1.2.3', '1.2.3'],
    ['v1.2.3', '1.2.3'],
    ['1.2.3-beta.1', '1.2.3-beta.1'],
    ['abc', '1.0.0'],
    ['1.2', '1.0.0'],
  ])('lerVersao(%p) → %p', (entrada, esperado) => {
    expect(lerVersao(entrada)).toBe(esperado);
  });

  it.each([
    [undefined, 1],
    ['', 1],
    ['12', 12],
    ['0', 1],
    ['-3', 1],
    ['1.5', 1],
    ['abc', 1],
    ['99999999999', 1],
  ])('lerVersionCode(%p) → %p', (entrada, esperado) => {
    expect(lerVersionCode(entrada)).toBe(esperado);
  });
});

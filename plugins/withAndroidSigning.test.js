const { readFileSync } = require('node:fs');
const { join } = require('node:path');

const { aplicarAssinatura, MARCADOR } = require('./withAndroidSigning');

const gradleOriginal = readFileSync(
  join(__dirname, '__fixtures__', 'app-build.gradle.txt'),
  'utf8',
);

function bloco(texto, nome, de = 0) {
  const i = texto.indexOf(`${nome} {`, de);
  if (i < 0) return null;
  let nivel = 0;
  for (let j = texto.indexOf('{', i); j < texto.length; j++) {
    if (texto[j] === '{') nivel++;
    if (texto[j] === '}' && --nivel === 0) return texto.slice(i, j + 1);
  }
  return null;
}

describe('withAndroidSigning', () => {
  const resultado = aplicarAssinatura(gradleOriginal);

  it('adiciona signingConfigs.release com storeType pkcs12 lendo o ambiente', () => {
    const signing = bloco(resultado, 'signingConfigs');
    expect(signing).toContain(MARCADOR);
    const release = bloco(signing, 'release');
    expect(release).toContain('storeType "pkcs12"');
    expect(release).toContain('System.getenv("ANDROID_KEYSTORE_PATH")');
    expect(release).toContain('System.getenv("KEYSTORE_PASSWORD")');
    expect(release).toContain('System.getenv("KEY_ALIAS")');
    expect(release).toContain('System.getenv("KEY_PASSWORD")');
    // a config debug continua lá
    expect(bloco(signing, 'debug')).toContain("storeFile file('debug.keystore')");
  });

  it('buildTypes.release usa a assinatura de release só se as 4 variáveis existirem', () => {
    const buildTypes = bloco(resultado, 'buildTypes');
    const release = bloco(buildTypes, 'release');
    expect(release).toMatch(
      /def assinaturaRelease = \(System\.getenv\("ANDROID_KEYSTORE_PATH"\) && System\.getenv\("KEYSTORE_PASSWORD"\) && System\.getenv\("KEY_ALIAS"\) && System\.getenv\("KEY_PASSWORD"\)\) \? signingConfigs\.release : signingConfigs\.debug\s+signingConfig assinaturaRelease/,
    );
    expect(release).not.toContain('signingConfig signingConfigs.debug');
    // debug build type intocado
    expect(bloco(buildTypes, 'debug')).toContain('signingConfig signingConfigs.debug');
  });

  it('sem variáveis o fallback é a assinatura debug (build não falha)', () => {
    const release = bloco(bloco(resultado, 'buildTypes'), 'release');
    expect(release).toContain(': signingConfigs.debug');
    // e o storeFile de release só é definido se ANDROID_KEYSTORE_PATH existir
    expect(bloco(bloco(resultado, 'signingConfigs'), 'release')).toContain('if (ksPath)');
  });

  it('é idempotente', () => {
    expect(aplicarAssinatura(resultado)).toBe(resultado);
    expect(resultado.split(MARCADOR)).toHaveLength(2);
  });

  it('chaves balanceadas e o resto do arquivo preservado', () => {
    const contar = (t, c) => t.split(c).length - 1;
    expect(contar(resultado, '{')).toBe(contar(resultado, '}'));
    expect(resultado).toContain('proguardFiles getDefaultProguardFile');
    expect(resultado.length).toBeGreaterThan(gradleOriginal.length);
  });

  it('falha com mensagem clara se o template mudar', () => {
    expect(() => aplicarAssinatura('android { }')).toThrow(/signingConfigs/);
  });

  it('o plugin exportado é uma função de config plugin', () => {
    const plugin = require('./withAndroidSigning');
    expect(typeof plugin).toBe('function');
    const config = plugin({ name: 'x', slug: 'x' });
    expect(config).toHaveProperty('mods.android.appBuildGradle');
  });
});

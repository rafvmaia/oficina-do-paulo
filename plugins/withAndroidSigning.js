// Config plugin: adiciona a assinatura de release (keystore PKCS12) ao
// android/app/build.gradle durante o `expo prebuild`.
//
// Lê do ambiente (no momento do Gradle): ANDROID_KEYSTORE_PATH, KEYSTORE_PASSWORD,
// KEY_ALIAS, KEY_PASSWORD. Se faltar alguma, o release continua com a
// assinatura debug do template — o build NÃO falha.
const { withAppBuildGradle } = require('expo/config-plugins');

const MARCADOR = '// @oficina-do-paulo/assinatura-release';

const BLOCO_SIGNING = `
        ${MARCADOR}
        release {
            def ksPath = System.getenv("ANDROID_KEYSTORE_PATH")
            if (ksPath) {
                storeFile file(ksPath)
                storeType "pkcs12"
                storePassword System.getenv("KEYSTORE_PASSWORD")
                keyAlias System.getenv("KEY_ALIAS")
                keyPassword System.getenv("KEY_PASSWORD")
            }
        }`;

const TEM_ASSINATURA = `(System.getenv("ANDROID_KEYSTORE_PATH") && System.getenv("KEYSTORE_PASSWORD") && System.getenv("KEY_ALIAS") && System.getenv("KEY_PASSWORD"))`;

/** Encontra o índice do `}` que fecha o bloco iniciado em `inicio` (posição do `{`). */
function fimDoBloco(texto, inicio) {
  let nivel = 0;
  for (let i = inicio; i < texto.length; i++) {
    if (texto[i] === '{') nivel++;
    else if (texto[i] === '}') {
      nivel--;
      if (nivel === 0) return i;
    }
  }
  return -1;
}

/** Localiza `nome {` dentro de [de, ate) e devolve {abre, fecha}. */
function acharBloco(texto, nome, de = 0, ate = texto.length) {
  const re = new RegExp(`(^|\\s)${nome}\\s*\\{`, 'g');
  re.lastIndex = de;
  const m = re.exec(texto);
  if (!m || m.index >= ate) return null;
  const abre = m.index + m[0].length - 1;
  const fecha = fimDoBloco(texto, abre);
  if (fecha < 0 || fecha > ate) return null;
  return { abre, fecha };
}

function aplicarAssinatura(gradle) {
  if (gradle.includes(MARCADOR)) return gradle;

  const signing = acharBloco(gradle, 'signingConfigs');
  if (!signing) throw new Error('withAndroidSigning: bloco signingConfigs não encontrado');
  let saida =
    gradle.slice(0, signing.fecha) + BLOCO_SIGNING + '\n    ' + gradle.slice(signing.fecha);

  const buildTypes = acharBloco(saida, 'buildTypes');
  if (!buildTypes) throw new Error('withAndroidSigning: bloco buildTypes não encontrado');
  const release = acharBloco(saida, 'release', buildTypes.abre, buildTypes.fecha);
  if (!release) throw new Error('withAndroidSigning: buildTypes.release não encontrado');

  const corpo = saida.slice(release.abre + 1, release.fecha);
  const novoCorpo = corpo.replace(
    /signingConfig\s+signingConfigs\.debug/,
    `def assinaturaRelease = ${TEM_ASSINATURA} ? signingConfigs.release : signingConfigs.debug\n            signingConfig assinaturaRelease`,
  );
  if (novoCorpo === corpo) {
    throw new Error('withAndroidSigning: signingConfig do release não encontrado');
  }
  saida = saida.slice(0, release.abre + 1) + novoCorpo + saida.slice(release.fecha);
  return saida;
}

const withAndroidSigning = (config) =>
  withAppBuildGradle(config, (cfg) => {
    if (cfg.modResults.language !== 'groovy') {
      throw new Error('withAndroidSigning: só build.gradle em Groovy é suportado');
    }
    cfg.modResults.contents = aplicarAssinatura(cfg.modResults.contents);
    return cfg;
  });

module.exports = withAndroidSigning;
module.exports.aplicarAssinatura = aplicarAssinatura;
module.exports.MARCADOR = MARCADOR;

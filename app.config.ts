import type { ConfigContext, ExpoConfig } from 'expo/config';

const VERSAO_PADRAO = '1.0.0';
const VERSION_CODE_PADRAO = 1;

/** `APP_VERSION` (aceita "v1.2.3") com padrão 1.0.0. */
export function lerVersao(valor: string | undefined): string {
  const limpo = (valor ?? '').trim().replace(/^v/i, '');
  return /^\d+\.\d+\.\d+([-+.][0-9A-Za-z.-]+)?$/.test(limpo) ? limpo : VERSAO_PADRAO;
}

/** `APP_VERSION_CODE` inteiro positivo, com padrão 1. */
export function lerVersionCode(valor: string | undefined): number {
  const texto = (valor ?? '').trim();
  if (!/^\d+$/.test(texto)) return VERSION_CODE_PADRAO;
  const numero = Number(texto);
  return numero >= 1 && numero <= 2100000000 ? numero : VERSION_CODE_PADRAO;
}

const GRAFITE = '#1F2A36';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'Oficina do Paulo',
  slug: 'oficina-do-paulo',
  scheme: 'oficinadopaulo',
  version: lerVersao(process.env.APP_VERSION),
  orientation: 'portrait',
  icon: './assets/icone/icone.png',
  userInterfaceStyle: 'automatic',
  backgroundColor: '#F4F5F7',
  android: {
    package: 'br.com.oficinadopaulo',
    versionCode: lerVersionCode(process.env.APP_VERSION_CODE),
    adaptiveIcon: {
      foregroundImage: './assets/icone/adaptive-frente.png',
      monochromeImage: './assets/icone/adaptive-monocromatico.png',
      backgroundColor: GRAFITE,
    },
    predictiveBackGestureEnabled: false,
  },
  plugins: [
    'expo-router',
    'expo-font',
    [
      'expo-splash-screen',
      {
        backgroundColor: GRAFITE,
        image: './assets/icone/splash.png',
        imageWidth: 240,
        dark: { backgroundColor: GRAFITE, image: './assets/icone/splash.png' },
      },
    ],
    './plugins/withAndroidSigning',
  ],
  experiments: {
    typedRoutes: true,
  },
});

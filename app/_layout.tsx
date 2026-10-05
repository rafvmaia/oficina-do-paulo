import { DarkTheme, DefaultTheme, Stack, ThemeProvider, type Theme } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useMemo } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { ProvedorTema, useTemaDoSistema, type TemaApp } from '@/theme';

function temaNavegacao(tema: TemaApp): Theme {
  const base = tema.esquema === 'escuro' ? DarkTheme : DefaultTheme;
  return {
    ...base,
    colors: {
      ...base.colors,
      primary: tema.app.primaria,
      background: tema.app.fundo,
      card: tema.app.superficie,
      text: tema.app.texto,
      border: tema.esquema === 'escuro' ? '#2C3A4A' : '#DDE1E6',
      notification: tema.app.pendente,
    },
  };
}

export default function LayoutRaiz() {
  const tema = useTemaDoSistema();
  const navegacao = useMemo(() => temaNavegacao(tema), [tema]);

  return (
    <SafeAreaProvider>
      <ProvedorTema tema={tema}>
        <ThemeProvider value={navegacao}>
          <StatusBar style="light" />
          <Stack
            screenOptions={{
              headerStyle: { backgroundColor: tema.app.grafite },
              headerTintColor: tema.app.sobreGrafite,
              contentStyle: { backgroundColor: tema.app.fundo },
            }}
          >
            <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
            <Stack.Screen name="configuracoes" options={{ title: 'Configurações' }} />
          </Stack>
        </ThemeProvider>
      </ProvedorTema>
    </SafeAreaProvider>
  );
}

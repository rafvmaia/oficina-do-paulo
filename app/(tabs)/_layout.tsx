import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import { useRouter } from 'expo-router';
import { Tabs } from 'expo-router/js-tabs';
import type { ComponentProps } from 'react';
import { IconButton } from 'react-native-paper';

import { useTemaApp } from '@/theme';

type NomeIcone = ComponentProps<typeof MaterialCommunityIcons>['name'];

export const ABAS: { nome: string; titulo: string; icone: NomeIcone }[] = [
  { nome: 'index', titulo: 'Início', icone: 'home' },
  { nome: 'clientes', titulo: 'Clientes', icone: 'account-group' },
  { nome: 'a-receber', titulo: 'A Receber', icone: 'cash-clock' },
  { nome: 'servicos', titulo: 'Serviços', icone: 'wrench' },
];

function BotaoConfiguracoes() {
  const router = useRouter();
  const tema = useTemaApp();
  return (
    <IconButton
      icon="cog"
      size={26}
      iconColor={tema.app.sobreGrafite}
      onPress={() => router.push('/configuracoes')}
      accessibilityLabel="Configurações"
      testID="btn-configuracoes"
      style={{ width: 48, height: 48 }}
    />
  );
}

export default function LayoutAbas() {
  const tema = useTemaApp();
  return (
    <Tabs
      screenOptions={{
        headerStyle: { backgroundColor: tema.app.grafite },
        headerTintColor: tema.app.sobreGrafite,
        headerTitleStyle: { fontWeight: '700' },
        headerRight: () => <BotaoConfiguracoes />,
        tabBarActiveTintColor: tema.app.primaria,
        tabBarInactiveTintColor: tema.app.textoSecundario,
        tabBarStyle: { backgroundColor: tema.app.superficie, minHeight: 64 },
        tabBarLabelStyle: { fontSize: 12, fontWeight: '600' },
        sceneStyle: { backgroundColor: tema.app.fundo },
      }}
    >
      {ABAS.map((aba) => (
        <Tabs.Screen
          key={aba.nome}
          name={aba.nome}
          options={{
            title: aba.titulo,
            tabBarAccessibilityLabel: aba.titulo,
            tabBarButtonTestID: `aba-${aba.nome}`,
            tabBarIcon: ({ color, size }) => (
              <MaterialCommunityIcons name={aba.icone} color={color} size={size} />
            ),
          }}
        />
      ))}
    </Tabs>
  );
}

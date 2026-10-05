import Constants from 'expo-constants';
import { ScrollView, StyleSheet } from 'react-native';
import { List } from 'react-native-paper';

import { supabaseConfigurado } from '@/lib/config';
import { useTemaApp } from '@/theme';

export default function TelaConfiguracoes() {
  const tema = useTemaApp();
  const versao = Constants.expoConfig?.version ?? '—';
  return (
    <ScrollView
      testID="tela-configuracoes"
      style={{ backgroundColor: tema.app.fundo }}
      contentContainerStyle={styles.conteudo}
    >
      <List.Section>
        <List.Subheader>Sobre o aplicativo</List.Subheader>
        <List.Item
          title="Versão"
          description={versao}
          left={(props) => <List.Icon {...props} icon="information-outline" />}
        />
        <List.Item
          testID="item-servidor"
          title="Servidor"
          description={supabaseConfigurado ? 'Configurado' : 'Servidor não configurado'}
          left={(props) => (
            <List.Icon
              {...props}
              icon={supabaseConfigurado ? 'cloud-check' : 'cloud-off-outline'}
            />
          )}
        />
        <List.Item
          title="Tema"
          description="Segue o modo claro/escuro do celular"
          left={(props) => <List.Icon {...props} icon="theme-light-dark" />}
        />
      </List.Section>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  conteudo: { paddingBottom: 24 },
});

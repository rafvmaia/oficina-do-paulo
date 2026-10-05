import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import type { ComponentProps } from 'react';
import { StyleSheet, View } from 'react-native';
import { Text } from 'react-native-paper';

import { useTemaApp } from '@/theme';

export interface EstadoVazioProps {
  icone: ComponentProps<typeof MaterialCommunityIcons>['name'];
  texto: string;
  /** Texto complementar opcional (ex.: dica do que fazer). */
  detalhe?: string;
  /** Ação opcional (ex.: um BotaoPrincipal). */
  acao?: React.ReactNode;
  testID?: string;
}

export function EstadoVazio({
  icone,
  texto,
  detalhe,
  acao,
  testID = 'estado-vazio',
}: EstadoVazioProps) {
  const tema = useTemaApp();
  return (
    <View testID={testID} style={styles.container}>
      <MaterialCommunityIcons
        testID={`${testID}-icone`}
        name={icone}
        size={72}
        color={tema.app.textoSecundario}
      />
      <Text variant="titleMedium" style={[styles.texto, { color: tema.app.texto }]}>
        {texto}
      </Text>
      {detalhe ? (
        <Text variant="bodyMedium" style={[styles.detalhe, { color: tema.app.textoSecundario }]}>
          {detalhe}
        </Text>
      ) : null}
      {acao ? <View style={styles.acao}>{acao}</View> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  texto: { textAlign: 'center' },
  detalhe: { textAlign: 'center' },
  acao: { alignSelf: 'stretch', marginTop: 12 },
});

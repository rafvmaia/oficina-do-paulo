import type { ComponentProps } from 'react';
import { StyleSheet } from 'react-native';
import { Button } from 'react-native-paper';

export const ALTURA_BOTAO_PRINCIPAL = 56;

export interface BotaoPrincipalProps {
  texto: string;
  onPress: () => void;
  icone?: ComponentProps<typeof Button>['icon'];
  desabilitado?: boolean;
  carregando?: boolean;
  modo?: 'contained' | 'outlined';
  accessibilityLabel?: string;
  testID?: string;
}

/** Botão de ação principal: 56dp de altura, largura total. */
export function BotaoPrincipal({
  texto,
  onPress,
  icone,
  desabilitado = false,
  carregando = false,
  modo = 'contained',
  accessibilityLabel,
  testID = 'botao-principal',
}: BotaoPrincipalProps) {
  return (
    <Button
      testID={testID}
      mode={modo}
      icon={icone}
      onPress={onPress}
      disabled={desabilitado || carregando}
      loading={carregando}
      accessibilityLabel={accessibilityLabel ?? texto}
      style={styles.botao}
      contentStyle={styles.conteudo}
      labelStyle={styles.rotulo}
    >
      {texto}
    </Button>
  );
}

const styles = StyleSheet.create({
  botao: { borderRadius: 12, alignSelf: 'stretch' },
  conteudo: { minHeight: ALTURA_BOTAO_PRINCIPAL, height: ALTURA_BOTAO_PRINCIPAL },
  rotulo: { fontSize: 17, fontWeight: '700' },
});

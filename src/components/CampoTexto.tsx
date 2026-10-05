import type { ComponentProps } from 'react';
import { StyleSheet, View } from 'react-native';
import { HelperText, TextInput } from 'react-native-paper';

type PropsTextInput = Omit<ComponentProps<typeof TextInput>, 'label' | 'error' | 'mode'>;

export interface CampoTextoProps extends PropsTextInput {
  rotulo: string;
  /** Mensagem de erro; quando presente o campo fica vermelho e a mensagem aparece. */
  erro?: string | null;
  testID?: string;
}

/** Campo de texto com rótulo e mensagem de erro abaixo. */
export function CampoTexto({ rotulo, erro, testID = 'campo-texto', ...resto }: CampoTextoProps) {
  const temErro = Boolean(erro);
  return (
    <View style={styles.container}>
      <TextInput
        testID={testID}
        mode="outlined"
        label={rotulo}
        accessibilityLabel={rotulo}
        error={temErro}
        style={styles.input}
        {...resto}
      />
      {temErro ? (
        <HelperText testID={`${testID}-erro`} type="error" visible>
          {erro}
        </HelperText>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { marginBottom: 8 },
  input: { minHeight: 56 },
});

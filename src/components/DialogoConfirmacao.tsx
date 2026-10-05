import { StyleSheet } from 'react-native';
import { Button, Dialog, Portal, Text } from 'react-native-paper';

import { useTemaApp } from '@/theme';

export interface DialogoConfirmacaoProps {
  visivel: boolean;
  titulo: string;
  mensagem: string;
  textoConfirmar?: string;
  textoCancelar?: string;
  /** Destaca o botão de confirmar em vermelho (ex.: excluir). */
  destrutivo?: boolean;
  onConfirmar: () => void;
  onCancelar: () => void;
  testID?: string;
}

/** Diálogo para confirmar ações (principalmente as destrutivas). */
export function DialogoConfirmacao({
  visivel,
  titulo,
  mensagem,
  textoConfirmar = 'Confirmar',
  textoCancelar = 'Cancelar',
  destrutivo = false,
  onConfirmar,
  onCancelar,
  testID = 'dialogo-confirmacao',
}: DialogoConfirmacaoProps) {
  const tema = useTemaApp();
  return (
    <Portal>
      <Dialog visible={visivel} onDismiss={onCancelar} testID={testID}>
        <Dialog.Title>{titulo}</Dialog.Title>
        <Dialog.Content>
          <Text variant="bodyMedium">{mensagem}</Text>
        </Dialog.Content>
        <Dialog.Actions>
          <Button
            testID={`${testID}-cancelar`}
            accessibilityLabel={textoCancelar}
            onPress={onCancelar}
            contentStyle={styles.botao}
          >
            {textoCancelar}
          </Button>
          <Button
            testID={`${testID}-confirmar`}
            accessibilityLabel={textoConfirmar}
            mode="contained"
            buttonColor={destrutivo ? tema.app.pendente : undefined}
            textColor={destrutivo ? tema.app.sobrePendente : undefined}
            onPress={onConfirmar}
            contentStyle={styles.botao}
          >
            {textoConfirmar}
          </Button>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
}

const styles = StyleSheet.create({
  botao: { minHeight: 48, paddingHorizontal: 8 },
});

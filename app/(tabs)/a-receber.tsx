import { EstadoVazio } from '@/components';

export default function TelaAReceber() {
  return (
    <EstadoVazio
      testID="tela-a-receber"
      icone="cash-check"
      texto="Nada a receber"
      detalhe="Serviços com pagamento pendente ou parcial aparecerão aqui."
    />
  );
}

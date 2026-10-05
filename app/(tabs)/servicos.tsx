import { EstadoVazio } from '@/components';

export default function TelaServicos() {
  return (
    <EstadoVazio
      testID="tela-servicos"
      icone="wrench-outline"
      texto="Nenhum serviço registrado"
      detalhe="Os serviços da oficina e a situação de pagamento de cada um aparecerão aqui."
    />
  );
}

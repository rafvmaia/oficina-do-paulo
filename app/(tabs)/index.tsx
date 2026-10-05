import { EstadoVazio } from '@/components';

export default function TelaInicio() {
  return (
    <EstadoVazio
      testID="tela-inicio"
      icone="garage"
      texto="Bem-vindo à Oficina do Paulo"
      detalhe="Ainda não há serviços registrados. O resumo do dia e os valores a receber aparecerão aqui."
    />
  );
}

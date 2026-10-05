import { EstadoVazio } from '@/components';

export default function TelaClientes() {
  return (
    <EstadoVazio
      testID="tela-clientes"
      icone="account-group-outline"
      texto="Nenhum cliente cadastrado"
      detalhe="Os clientes e seus veículos aparecerão aqui."
    />
  );
}

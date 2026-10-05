/** Paleta oficial da Oficina do Paulo (ver agentes/CONTEXTO.md). */
export interface PaletaApp {
  primaria: string;
  primariaPressionada: string;
  grafite: string;
  fundo: string;
  superficie: string;
  texto: string;
  textoSecundario: string;
  pago: string;
  parcial: string;
  pendente: string;
  /** Cor do texto/ícone sobre o fundo de cada status. */
  sobrePago: string;
  sobreParcial: string;
  sobrePendente: string;
  /** Texto sobre a barra grafite do cabeçalho. */
  sobreGrafite: string;
}

export const coresClaro: PaletaApp = {
  primaria: '#E8630A',
  primariaPressionada: '#B84D05',
  grafite: '#1F2A36',
  fundo: '#F4F5F7',
  superficie: '#FFFFFF',
  texto: '#1A1A1A',
  textoSecundario: '#5F6B7A',
  pago: '#2E7D32',
  parcial: '#F9A825',
  pendente: '#C62828',
  sobrePago: '#FFFFFF',
  sobreParcial: '#1A1A1A',
  sobrePendente: '#FFFFFF',
  sobreGrafite: '#FFFFFF',
};

export const coresEscuro: PaletaApp = {
  primaria: '#FF7A1F',
  primariaPressionada: '#E8630A',
  grafite: '#1F2A36',
  fundo: '#121820',
  superficie: '#1F2A36',
  texto: '#ECEFF3',
  textoSecundario: '#A9B4C2',
  pago: '#66BB6A',
  parcial: '#FFCA28',
  pendente: '#EF5350',
  sobrePago: '#121820',
  sobreParcial: '#121820',
  sobrePendente: '#121820',
  sobreGrafite: '#ECEFF3',
};

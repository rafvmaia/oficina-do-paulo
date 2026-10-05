// Gera os ícones e a splash do app a partir de SVGs desenhados aqui.
// Uso: node scripts/gerar-icones.mjs  (os PNGs gerados são versionados em assets/icone)
import { Resvg } from '@resvg/resvg-js';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = join(dirname(fileURLToPath(import.meta.url)), '..', 'assets', 'icone');
mkdirSync(raiz, { recursive: true });

const LARANJA = '#E8630A';
const GRAFITE = '#1F2A36';
const CLARO = '#ECEFF3';

function engrenagem(cor, furo) {
  const dentes = Array.from({ length: 10 }, (_, i) => {
    const angulo = i * 36;
    return `<rect x="467" y="182" width="90" height="120" rx="14" fill="${cor}" transform="rotate(${angulo} 512 512)"/>`;
  }).join('');
  return `${dentes}<circle cx="512" cy="512" r="250" fill="${cor}"/><circle cx="512" cy="512" r="105" fill="${furo}"/>`;
}

function chave(cor, contorno) {
  const forma = (preenchimento, extra) =>
    `<g mask="url(#boca)" transform="rotate(-45 512 512)">` +
    `<rect x="${472 - extra}" y="${240 - extra}" width="${80 + 2 * extra}" height="${660 + 2 * extra}" rx="${40 + extra}" fill="${preenchimento}"/>` +
    `<circle cx="512" cy="215" r="${118 + extra}" fill="${preenchimento}"/>` +
    `<circle cx="512" cy="855" r="${62 + extra}" fill="${preenchimento}"/>` +
    `</g>`;
  const mascara =
    `<mask id="boca" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">` +
    `<rect x="0" y="0" width="1024" height="1024" fill="#fff"/>` +
    `<rect x="476" y="60" width="72" height="170" rx="10" fill="#000"/>` +
    `<circle cx="512" cy="855" r="26" fill="#000"/>` +
    `</mask>`;
  return `<defs>${mascara}</defs>${contorno ? forma(contorno, 22) : ''}${forma(cor, 0)}`;
}

function desenho({ escala, fundo, corEngrenagem, corFuro, corChave, contorno }) {
  const conteudo = `${engrenagem(corEngrenagem, corFuro)}${chave(corChave, contorno)}`;
  const fundoSvg = fundo ? `<rect width="1024" height="1024" fill="${fundo}"/>` : '';
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">` +
    `${fundoSvg}<g transform="translate(512 512) scale(${escala}) translate(-512 -512)">${conteudo}</g></svg>`
  );
}

function salvar(nome, svg, largura = 1024) {
  writeFileSync(join(raiz, nome.replace('.png', '.svg')), svg);
  const png = new Resvg(svg, {
    fitTo: { mode: 'width', value: largura },
    font: { loadSystemFonts: true },
  })
    .render()
    .asPng();
  writeFileSync(join(raiz, nome), png);
  console.log(`gerado ${nome}`);
}

const padrao = { corEngrenagem: LARANJA, corFuro: GRAFITE, corChave: CLARO, contorno: GRAFITE };

// Ícone legado (quadrado, fundo grafite)
salvar('icone.png', desenho({ ...padrao, escala: 0.82, fundo: GRAFITE }));
// Adaptive icon: frente transparente dentro da zona segura (66%)
salvar('adaptive-frente.png', desenho({ ...padrao, escala: 0.6, fundo: null }));
// Ícone monocromático (Android 13+)
salvar(
  'adaptive-monocromatico.png',
  desenho({
    escala: 0.6,
    fundo: null,
    corEngrenagem: '#FFFFFF',
    corFuro: '#000000',
    corChave: '#FFFFFF',
    contorno: '#000000',
  }).replace(/#000000/g, 'transparent'),
);

// Splash: ícone + nome
const splash =
  `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1280" viewBox="0 0 1024 1280">` +
  `<g transform="translate(512 470) scale(0.8) translate(-512 -512)">${engrenagem(LARANJA, GRAFITE)}${chave(CLARO, GRAFITE)}</g>` +
  `<text x="512" y="1160" text-anchor="middle" font-family="Helvetica, Arial, sans-serif" font-weight="700" font-size="112" fill="${CLARO}">Oficina do Paulo</text>` +
  `</svg>`;
salvar('splash.png', splash);

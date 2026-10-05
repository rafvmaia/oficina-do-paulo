package br.com.oficinadopaulo.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Contrast
import androidx.compose.material.icons.filled.Error
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.SemanticsPropertyKey
import androidx.compose.ui.semantics.SemanticsPropertyReceiver
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import br.com.oficinadopaulo.domain.StatusPagamento
import br.com.oficinadopaulo.ui.theme.CoresOficina
import br.com.oficinadopaulo.ui.theme.OficinaTema

/** Cor de fundo do chip, exposta na semântica para os testes de tela conferirem a cor. */
val CorStatusKey = SemanticsPropertyKey<Color>("CorStatus")
var SemanticsPropertyReceiver.corStatus by CorStatusKey

/** Ícone exibido para cada status (✓ PAGO / ◐ PARCIAL / ! PENDENTE). */
fun StatusPagamento.icone(): ImageVector = when (this) {
    StatusPagamento.PAGO -> Icons.Filled.CheckCircle
    StatusPagamento.PARCIAL -> Icons.Filled.Contrast
    StatusPagamento.PENDENTE -> Icons.Filled.Error
}

/** Par (fundo, conteúdo) de cores do status no tema atual. */
fun StatusPagamento.cores(cores: CoresOficina): Pair<Color, Color> = when (this) {
    StatusPagamento.PAGO -> cores.pago to cores.conteudoPago
    StatusPagamento.PARCIAL -> cores.parcial to cores.conteudoParcial
    StatusPagamento.PENDENTE -> cores.pendente to cores.conteudoPendente
}

/**
 * Chip de status de pagamento: SEMPRE cor + ícone + texto, para ser impossível confundir.
 */
@Composable
fun StatusPagamentoChip(
    status: StatusPagamento,
    modifier: Modifier = Modifier,
) {
    val (fundo, conteudo) = status.cores(OficinaTema.cores)
    Row(
        modifier = modifier
            .testTag("chip_status_pagamento")
            .semantics(mergeDescendants = true) { corStatus = fundo }
            .heightIn(min = 32.dp)
            .background(fundo, MaterialTheme.shapes.small)
            .padding(horizontal = 10.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Icon(
            imageVector = status.icone(),
            // O texto ao lado já descreve o status; o ícone é reforço visual.
            contentDescription = null,
            tint = conteudo,
            modifier = Modifier
                .size(18.dp)
                .testTag("icone_status_${status.name.lowercase()}"),
        )
        Text(
            text = status.rotulo,
            color = conteudo,
            style = MaterialTheme.typography.labelMedium,
        )
    }
}

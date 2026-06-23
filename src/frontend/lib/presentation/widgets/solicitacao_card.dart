import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/solicitacao.dart';
import 'status_chip.dart';

class SolicitacaoCard extends StatelessWidget {
  const SolicitacaoCard({
    required this.solicitacao,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final Solicitacao solicitacao;
  final VoidCallback onTap;
  final Widget? trailing;

  static const _title = Color(0xFF0F172A);
  static const _text = Color(0xFF334155);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _softSurface = Color(0xFFF8FAFC);
  static const _moneyGreen = Color(0xFF15803D);
  static const _moneyGreenSoft = Color(0xFFF0FDF4);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      solicitacao.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _title,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(status: solicitacao.status, label: solicitacao.statusLabel),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                solicitacao.descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _text,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CardPill(
                    icon: Icons.payments_outlined,
                    label: Formatters.money(solicitacao.orcamento),
                    foregroundColor: _moneyGreen,
                    backgroundColor: _moneyGreenSoft,
                    strong: true,
                  ),
                  _CardPill(
                    icon: Icons.event_outlined,
                    label: Formatters.shortDate(solicitacao.prazoEntrega),
                    foregroundColor: _muted,
                    backgroundColor: _softSurface,
                  ),
                  _CardPill(
                    icon: Icons.category_outlined,
                    label: _formatCategoria(solicitacao.categoria),
                    foregroundColor: _muted,
                    backgroundColor: _softSurface,
                  ),
                  if (solicitacao.clienteNome != null)
                    _CardPill(
                      icon: Icons.person_outline,
                      label: solicitacao.clienteNome!,
                      foregroundColor: _muted,
                      backgroundColor: _softSurface,
                    ),
                ],
              ),
              if (trailing != null) ...[const SizedBox(height: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCategoria(String value) {
    switch (value) {
      case 'programacao':
        return 'Programação';
      case 'design':
        return 'Design';
      case 'video':
        return 'Vídeo';
      case 'traducao':
        return 'Tradução';
      case 'geral':
        return 'Geral';
      default:
        return value;
    }
  }
}

class _CardPill extends StatelessWidget {
  const _CardPill({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.strong = false,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool strong;

  static const _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: strong ? Colors.transparent : _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: strong ? -0.2 : 0,
                ),
          ),
        ],
      ),
    );
  }
}
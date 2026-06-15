import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/solicitacao.dart';
import 'status_chip.dart';

class SolicitacaoCard extends StatelessWidget {
  const SolicitacaoCard({
    required this.solicitacao,
    required this.onTap,
    super.key,
  });

  final Solicitacao solicitacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
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
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(
                    status: solicitacao.status,
                    label: solicitacao.statusLabel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                solicitacao.descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.64),
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(
                    icon: Icons.payments_outlined,
                    label: Formatters.money(solicitacao.orcamento),
                  ),
                  _InfoPill(
                    icon: Icons.schedule_outlined,
                    label: Formatters.shortDate(solicitacao.prazoEntrega),
                  ),
                  _InfoPill(
                    icon: Icons.category_outlined,
                    label: solicitacao.categoria,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withOpacity(0.56)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

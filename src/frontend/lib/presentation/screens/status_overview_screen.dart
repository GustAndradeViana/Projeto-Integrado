import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/solicitacao.dart';
import '../controllers/solicitacoes_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';
import 'solicitacao_detail_screen.dart';

class StatusOverviewScreen extends StatelessWidget {
  const StatusOverviewScreen({required this.controller, super.key});

  final SolicitacoesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.solicitacoes;
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
            children: [
              Text(
                'Estados do fluxo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.clock(controller.lastSync),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.62),
                    ),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    icon: Icons.query_stats_outlined,
                    title: 'Sem historico',
                    message: 'As mudancas de estado aparecem nesta tela.',
                  ),
                )
              else
                ...[
                  _StatusSection(
                    title: 'Abertas',
                    icon: Icons.radio_button_checked,
                    items: _filter(items, 'aberta'),
                    controller: controller,
                  ),
                  _StatusSection(
                    title: 'Em andamento',
                    icon: Icons.bolt_outlined,
                    items: _filter(items, 'em_andamento'),
                    controller: controller,
                  ),
                  _StatusSection(
                    title: 'Concluidas',
                    icon: Icons.done_all_outlined,
                    items: _filter(items, 'concluida'),
                    controller: controller,
                  ),
                  _StatusSection(
                    title: 'Canceladas',
                    icon: Icons.close,
                    items: _filter(items, 'cancelada'),
                    controller: controller,
                  ),
                ],
            ],
          ),
        );
      },
    );
  }

  static List<Solicitacao> _filter(List<Solicitacao> items, String status) {
    return items.where((item) => item.status == status).toList();
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.controller,
  });

  final String title;
  final IconData icon;
  final List<Solicitacao> items;
  final SolicitacoesController controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  title: Text(
                    item.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(Formatters.money(item.orcamento)),
                  trailing: StatusChip(
                    status: item.status,
                    label: item.statusLabel,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SolicitacaoDetailScreen(
                          controller: controller,
                          solicitacaoId: item.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

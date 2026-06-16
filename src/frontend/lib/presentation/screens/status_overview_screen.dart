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

  static const _title = Color(0xFF0F172A);
  static const _text = Color(0xFF334155);
  static const _muted = Color(0xFF64748B);
  static const _moneyGreen = Color(0xFF15803D);
  static const _softGreen = Color(0xFFF0FDF4);
  static const _softYellow = Color(0xFFFFFBEB);
  static const _softDark = Color(0xFFF1F5F9);
  static const _softRed = Color(0xFFFEF2F2);

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
                'Status do fluxo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _title,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.clock(controller.lastSync),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    icon: Icons.query_stats_outlined,
                    title: 'Sem histórico',
                    message: 'As mudanças de status aparecem nesta tela.',
                  ),
                )
              else ...[
                _StatusSection(
                  title: 'Abertas',
                  icon: Icons.radio_button_checked,
                  color: const Color(0xFF16A34A),
                  backgroundColor: _softGreen,
                  items: _filter(items, 'aberta'),
                  controller: controller,
                ),
                _StatusSection(
                  title: 'Em andamento',
                  icon: Icons.bolt_outlined,
                  color: const Color(0xFFD97706),
                  backgroundColor: _softYellow,
                  items: _filter(items, 'em_andamento'),
                  controller: controller,
                ),
                _StatusSection(
                  title: 'Concluídas',
                  icon: Icons.done_all_outlined,
                  color: _title,
                  backgroundColor: _softDark,
                  items: _filter(items, 'concluida'),
                  controller: controller,
                ),
                _StatusSection(
                  title: 'Canceladas',
                  icon: Icons.close,
                  color: const Color(0xFFDC2626),
                  backgroundColor: _softRed,
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
    required this.color,
    required this.backgroundColor,
    required this.items,
    required this.controller,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final List<Solicitacao> items;
  final SolicitacoesController controller;

  static const _title = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _moneyGreen = Color(0xFF15803D);

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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _title,
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(
                    item.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _title,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      Formatters.money(item.orcamento),
                      style: const TextStyle(
                        color: _moneyGreen,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
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
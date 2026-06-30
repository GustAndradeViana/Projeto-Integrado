import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../controllers/prestador_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';
import 'chat_screen.dart';

class PrestadorPropostasScreen extends StatelessWidget {
  const PrestadorPropostasScreen({
    required this.controller,
    required this.repository,
    required this.usuario,
    super.key,
  });

  final PrestadorController controller;
  final QuickFreelaRepository repository;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final propostas = controller.minhasPropostas;

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minhas propostas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.clock(controller.lastSync),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (propostas.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.send_outlined,
                    title: 'Nenhuma proposta enviada',
                    message: 'Encontre demandas na aba "Demandas" e envie propostas.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: propostas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final proposta = propostas[index];
                      final isAceita = proposta.status == 'aceita';

                      return Card(
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
                                      proposta.solicitacaoTitulo ?? 'Demanda #${proposta.solicitacaoId}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0F172A),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusChip(
                                    status: proposta.status,
                                    label: proposta.statusLabel,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                proposta.mensagem,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF334155),
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Pill(
                                    icon: Icons.payments_outlined,
                                    label: Formatters.money(proposta.valor),
                                    isMoney: true,
                                  ),
                                  _Pill(
                                    icon: Icons.schedule_outlined,
                                    label: '${proposta.prazoDias} dias',
                                  ),
                                ],
                              ),
                              if (isAceita) ...[
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final sol = await repository.buscarSolicitacao(proposta.solicitacaoId);
                                    if (!context.mounted) return;
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ChatScreen(
                                          solicitacao: sol,
                                          usuarioId: usuario.id,
                                          repository: repository,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('Abrir chat'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, this.isMoney = false});

  final IconData icon;
  final String label;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    final color = isMoney ? const Color(0xFF16A34A) : const Color(0xFF475569);
    final bg = isMoney ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
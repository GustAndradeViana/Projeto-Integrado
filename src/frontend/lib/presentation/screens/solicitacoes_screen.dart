import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../controllers/solicitacoes_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_tile.dart';
import '../widgets/solicitacao_card.dart';
import 'criar_solicitacao_screen.dart';
import 'solicitacao_detail_screen.dart';

class SolicitacoesScreen extends StatelessWidget {
  const SolicitacoesScreen({required this.controller, super.key});

  final SolicitacoesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(controller: controller),
              ),
              if (controller.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage != null &&
                  controller.solicitacoes.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Backend indisponível',
                    message: 'Confira se o Flask está rodando na URL da API.',
                  ),
                )
              else if (controller.solicitacoes.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.assignment_add,
                    title: 'Nenhuma solicitação ainda',
                    message: 'Crie uma demanda rápida para receber propostas.',
                    action: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CriarSolicitacaoScreen(
                              controller: controller,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Criar agora'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: controller.solicitacoes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final solicitacao = controller.solicitacoes[index];

                      return SolicitacaoCard(
                        solicitacao: solicitacao,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SolicitacaoDetailScreen(
                                controller: controller,
                                solicitacaoId: solicitacao.id,
                              ),
                            ),
                          );
                        },
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

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final SolicitacoesController controller;

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);
    const border = Color(0xFFE2E8F0);
    const surfaceSoft = Color(0xFFF1F5F9);

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: titleColor,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QuickFreela', style: titleStyle),
                    const SizedBox(height: 4),
                    Text(
                      'Cliente: Ana Cliente',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              if (controller.isRefreshing)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: () => controller.refresh(),
                  icon: const Icon(Icons.sync_outlined),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: titleColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painel de demandas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.clock(controller.lastSync),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MetricTile(
                label: 'Abertas',
                value: controller.countByStatus('aberta').toString(),
                icon: Icons.radio_button_checked,
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(width: 10),
              MetricTile(
                label: 'Andamento',
                value: controller.countByStatus('em_andamento').toString(),
                icon: Icons.bolt_outlined,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              MetricTile(
                label: 'Concluídas',
                value: controller.countByStatus('concluida').toString(),
                icon: Icons.done_all_outlined,
                color: const Color(0xFF0F172A),
              ),
            ],
          ),
          if (controller.errorMessage != null &&
              controller.solicitacoes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              controller.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
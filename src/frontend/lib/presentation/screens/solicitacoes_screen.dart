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
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Backend indisponivel',
                    message: 'Confira se o Flask esta rodando na URL da API.',
                  ),
                )
              else if (controller.solicitacoes.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.assignment_add,
                    title: 'Nenhuma solicitacao ainda',
                    message: 'Crie uma demanda rapida para receber propostas.',
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
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
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
                    const SizedBox(height: 3),
                    Text(
                      'Cliente: Ana Cliente',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.58),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel de demandas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.clock(controller.lastSync),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.74),
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
                color: const Color(0xFF2A9D8F),
              ),
              const SizedBox(width: 10),
              MetricTile(
                label: 'Andamento',
                value: controller.countByStatus('em_andamento').toString(),
                icon: Icons.bolt_outlined,
                color: const Color(0xFFF4A261),
              ),
              const SizedBox(width: 10),
              MetricTile(
                label: 'Concluidas',
                value: controller.countByStatus('concluida').toString(),
                icon: Icons.done_all_outlined,
                color: const Color(0xFF3A7D44),
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
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

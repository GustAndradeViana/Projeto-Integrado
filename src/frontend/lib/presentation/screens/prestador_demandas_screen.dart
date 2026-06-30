import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../controllers/prestador_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/solicitacao_card.dart';
import 'prestador_solicitacao_detail_screen.dart';

class PrestadorDemandasScreen extends StatelessWidget {
  const PrestadorDemandasScreen({
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
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(controller: controller, usuario: usuario),
              ),
              if (controller.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage != null && controller.solicitacoes.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Backend indisponível',
                    message: 'Confira se o Flask está rodando na URL da API.',
                  ),
                )
              else if (controller.solicitacoes.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Sem demandas abertas',
                    message: 'Nenhuma demanda disponível no momento. Volte em breve.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: controller.solicitacoes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final solicitacao = controller.solicitacoes[index];
                      final jaMandou = controller.jaMandouProposta(solicitacao.id);
                      return SolicitacaoCard(
                        solicitacao: solicitacao,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PrestadorSolicitacaoDetailScreen(
                                solicitacao: solicitacao,
                                controller: controller,
                                repository: repository,
                                usuario: usuario,
                              ),
                            ),
                          );
                        },
                        trailing: jaMandou
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Proposta enviada',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,
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
  const _Header({required this.controller, required this.usuario});

  final PrestadorController controller;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);
    const border = Color(0xFFE2E8F0);
    const surfaceSoft = Color(0xFFF1F5F9);

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
                    Text(
                      'QuickFreela',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prestador: ${usuario.nome}',
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
          const SizedBox(height: 16),
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
                  child: const Icon(Icons.work_outline, color: titleColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demandas abertas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.solicitacoes.length} disponíveis  •  ${Formatters.clock(controller.lastSync)}',
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
        ],
      ),
    );
  }
}
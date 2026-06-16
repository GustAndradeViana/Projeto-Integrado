import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/proposta.dart';
import '../../domain/entities/solicitacao.dart';
import '../controllers/solicitacoes_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';

class SolicitacaoDetailScreen extends StatefulWidget {
  const SolicitacaoDetailScreen({
    required this.controller,
    required this.solicitacaoId,
    super.key,
  });

  final SolicitacoesController controller;
  final int solicitacaoId;

  @override
  State<SolicitacaoDetailScreen> createState() =>
      _SolicitacaoDetailScreenState();
}

class _SolicitacaoDetailScreenState extends State<SolicitacaoDetailScreen> {
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.controller.loadDetails(widget.solicitacaoId));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final solicitacao = widget.controller.findById(widget.solicitacaoId);
        final propostas =
            widget.controller.propostasDaSolicitacao(widget.solicitacaoId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes'),
            actions: [
              IconButton(
                tooltip: 'Atualizar',
                onPressed: () =>
                    widget.controller.loadDetails(widget.solicitacaoId),
                icon: const Icon(Icons.sync_outlined),
              ),
            ],
          ),
          body: solicitacao == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _SummaryCard(solicitacao: solicitacao),
                    const SizedBox(height: 14),
                    _DescriptionCard(solicitacao: solicitacao),
                    const SizedBox(height: 14),
                    _ActionsCard(
                      solicitacao: solicitacao,
                      isLoading: _isUpdatingStatus,
                      onStatusChange: _updateStatus,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Propostas recebidas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (propostas.isEmpty)
                      const SizedBox(
                        height: 190,
                        child: EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Sem propostas por enquanto',
                          message:
                              'Quando um prestador enviar uma proposta, ela aparecerá aqui.',
                        ),
                      )
                    else
                      ...propostas.map(
                        (proposta) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PropostaCard(proposta: proposta),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdatingStatus = true);

    try {
      await widget.controller.updateStatus(widget.solicitacaoId, status);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para $status')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.solicitacao});

  final Solicitacao solicitacao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    solicitacao.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailPill(
                  icon: Icons.payments_outlined,
                  label: Formatters.money(solicitacao.orcamento),
                  isMoney: true,
                ),
                _DetailPill(
                  icon: Icons.event_outlined,
                  label: Formatters.shortDate(solicitacao.prazoEntrega),
                ),
                _DetailPill(
                  icon: Icons.category_outlined,
                  label: solicitacao.categoria,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.solicitacao});

  final Solicitacao solicitacao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              solicitacao.descricao,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.42,
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (solicitacao.prestadorNome != null) ...[
              const SizedBox(height: 16),
              _DetailPill(
                icon: Icons.person_pin_circle_outlined,
                label: 'Prestador: ${solicitacao.prestadorNome}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.solicitacao,
    required this.isLoading,
    required this.onStatusChange,
  });

  final Solicitacao solicitacao;
  final bool isLoading;
  final ValueChanged<String> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (solicitacao.isAberta) {
      actions.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(
              color: Color(0xFFFCA5A5),
              width: 1.3,
            ),
          ),
          onPressed: isLoading ? null : () => onStatusChange('cancelada'),
          icon: const Icon(Icons.close),
          label: const Text('Cancelar'),
        ),
      );
    }

    if (solicitacao.isEmAndamento) {
      actions.add(
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => onStatusChange('concluida'),
          icon: const Icon(Icons.done_all),
          label: const Text('Concluir serviço'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ação principal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const LinearProgressIndicator()
            else if (actions.isEmpty)
              Text(
                'Nenhuma ação disponível para este status.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
              )
            else
              Column(
                children: actions
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _PropostaCard extends StatelessWidget {
  const _PropostaCard({required this.proposta});

  final Proposta proposta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    proposta.prestadorNome ?? 'Prestador #${proposta.prestadorId}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                  ),
                ),
                StatusChip(
                  status: proposta.status,
                  label: proposta.statusLabel,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              proposta.mensagem,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailPill(
                  icon: Icons.payments_outlined,
                  label: Formatters.money(proposta.valor),
                  isMoney: true,
                ),
                _DetailPill(
                  icon: Icons.schedule_outlined,
                  label: '${proposta.prazoDias} dias',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.label,
    this.isMoney = false,
  });

  final IconData icon;
  final String label;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    final color = isMoney
        ? const Color(0xFF16A34A)
        : const Color(0xFF475569);

    final background = isMoney
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
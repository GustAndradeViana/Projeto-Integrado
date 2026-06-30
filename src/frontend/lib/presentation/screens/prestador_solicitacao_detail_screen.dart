import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../controllers/prestador_controller.dart';
import '../widgets/status_chip.dart';
import 'chat_screen.dart';

class PrestadorSolicitacaoDetailScreen extends StatefulWidget {
  const PrestadorSolicitacaoDetailScreen({
    required this.solicitacao,
    required this.controller,
    required this.repository,
    required this.usuario,
    super.key,
  });

  final Solicitacao solicitacao;
  final PrestadorController controller;
  final QuickFreelaRepository repository;
  final Usuario usuario;

  @override
  State<PrestadorSolicitacaoDetailScreen> createState() =>
      _PrestadorSolicitacaoDetailScreenState();
}

class _PrestadorSolicitacaoDetailScreenState extends State<PrestadorSolicitacaoDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _prazoController = TextEditingController(text: '3');
  final _mensagemController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _valorController.dispose();
    _prazoController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final jaMandou = widget.controller.jaMandouProposta(widget.solicitacao.id);
        final minhaProposta = widget.controller.minhaProposta(widget.solicitacao.id);
        final sol = widget.solicitacao;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Demanda'),
            actions: [
              if (sol.isEmAndamento && sol.prestadorId == widget.usuario.id)
                IconButton(
                  tooltip: 'Abrir chat',
                  onPressed: () => _openChat(sol),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Card(
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
                              sol.titulo,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusChip(status: sol.status, label: sol.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Pill(
                            icon: Icons.payments_outlined,
                            label: Formatters.money(sol.orcamento),
                            isMoney: true,
                          ),
                          _Pill(
                            icon: Icons.event_outlined,
                            label: Formatters.shortDate(sol.prazoEntrega),
                          ),
                          _Pill(
                            icon: Icons.category_outlined,
                            label: sol.categoria,
                          ),
                          if (sol.clienteNome != null)
                            _Pill(
                              icon: Icons.person_outline,
                              label: sol.clienteNome!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
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
                        sol.descricao,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: const Color(0xFF334155),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (sol.isEmAndamento && sol.prestadorId == widget.usuario.id) ...[
                ElevatedButton.icon(
                  onPressed: () => _openChat(sol),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Abrir chat com cliente'),
                ),
              ] else if (!sol.isAberta) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF64748B)),
                      SizedBox(width: 10),
                      Text(
                        'Esta demanda não está mais aberta.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (jaMandou && minhaProposta != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sua proposta',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),
                            const Spacer(),
                            StatusChip(
                              status: minhaProposta.status,
                              label: minhaProposta.statusLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          minhaProposta.mensagem,
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
                              label: Formatters.money(minhaProposta.valor),
                              isMoney: true,
                            ),
                            _Pill(
                              icon: Icons.schedule_outlined,
                              label: '${minhaProposta.prazoDias} dias',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Enviar proposta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _valorController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w900,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Seu valor',
                              prefixText: 'R\$ ',
                              prefixIcon: Icon(Icons.payments_outlined, color: Color(0xFF16A34A)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe o valor';
                              final parsed = double.tryParse(v.replaceAll(',', '.'));
                              if (parsed == null || parsed <= 0) return 'Valor inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _prazoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Prazo (dias)',
                              prefixIcon: Icon(Icons.schedule_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe o prazo';
                              final parsed = int.tryParse(v);
                              if (parsed == null || parsed <= 0) return 'Prazo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _mensagemController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Sua mensagem',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.message_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Escreva uma mensagem';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          if (_isSending)
                            const LinearProgressIndicator()
                          else
                            ElevatedButton.icon(
                              onPressed: _enviarProposta,
                              icon: const Icon(Icons.send_outlined),
                              label: const Text('Enviar proposta'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openChat(Solicitacao sol) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          solicitacao: sol,
          usuarioId: widget.usuario.id,
          repository: widget.repository,
        ),
      ),
    );
  }

  Future<void> _enviarProposta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      await widget.controller.enviarProposta(
        solicitacaoId: widget.solicitacao.id,
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        prazoDias: int.parse(_prazoController.text),
        mensagem: _mensagemController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposta enviada com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
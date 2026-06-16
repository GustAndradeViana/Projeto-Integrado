import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../domain/entities/criar_solicitacao_input.dart';
import '../controllers/solicitacoes_controller.dart';
import 'solicitacao_detail_screen.dart';

class CriarSolicitacaoScreen extends StatefulWidget {
  const CriarSolicitacaoScreen({required this.controller, super.key});

  final SolicitacoesController controller;

  @override
  State<CriarSolicitacaoScreen> createState() => _CriarSolicitacaoScreenState();
}

class _CriarSolicitacaoScreenState extends State<CriarSolicitacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _orcamentoController = TextEditingController(text: '150');
  final _prazoController = TextEditingController();

  String _categoria = 'programacao';
  bool _isSaving = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _orcamentoController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);
    const moneyGreen = Color(0xFF16A34A);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova solicitação')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            'Abrir demanda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Descreva uma tarefa curta para receber propostas objetivas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descricaoController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'programacao',
                          child: Text('Programação'),
                        ),
                        DropdownMenuItem(
                          value: 'design',
                          child: Text('Design'),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text('Vídeo'),
                        ),
                        DropdownMenuItem(
                          value: 'traducao',
                          child: Text('Tradução'),
                        ),
                        DropdownMenuItem(
                          value: 'geral',
                          child: Text('Geral'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _categoria = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _orcamentoController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: moneyGreen,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Orçamento',
                        prefixText: 'R\$ ',
                        prefixStyle: TextStyle(
                          color: moneyGreen,
                          fontWeight: FontWeight.w900,
                        ),
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          color: moneyGreen,
                        ),
                      ),
                      validator: _moneyValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prazoController,
                      decoration: const InputDecoration(
                        labelText: 'Prazo desejado',
                        hintText: '2026-05-30',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_isSaving)
                      const LinearProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const Text('Publicar solicitação'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _moneyValidator(String? value) {
    final requiredError = _required(value);

    if (requiredError != null) {
      return requiredError;
    }

    final parsed = double.tryParse(value!.replaceAll(',', '.'));

    if (parsed == null || parsed < 0) {
      return 'Informe um valor válido';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final created = await widget.controller.create(
        CriarSolicitacaoInput(
          clienteId: AppConfig.clienteId,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          categoria: _categoria,
          orcamento: double.parse(_orcamentoController.text.replaceAll(',', '.')),
          prazoEntrega: _prazoController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SolicitacaoDetailScreen(
            controller: widget.controller,
            solicitacaoId: created.id,
          ),
        ),
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
        setState(() => _isSaving = false);
      }
    }
  }
}
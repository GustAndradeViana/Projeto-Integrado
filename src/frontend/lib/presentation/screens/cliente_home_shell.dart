import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../../domain/usecases/atualizar_status_solicitacao.dart';
import '../../domain/usecases/buscar_solicitacao.dart';
import '../../domain/usecases/criar_solicitacao.dart';
import '../../domain/usecases/listar_propostas_solicitacao.dart';
import '../../domain/usecases/listar_solicitacoes_cliente.dart';
import '../controllers/solicitacoes_controller.dart';
import 'criar_solicitacao_screen.dart';
import 'solicitacoes_screen.dart';
import 'status_overview_screen.dart';

class ClienteHomeShell extends StatefulWidget {
  const ClienteHomeShell({required this.repository, super.key});

  final QuickFreelaRepository repository;

  @override
  State<ClienteHomeShell> createState() => _ClienteHomeShellState();
}

class _ClienteHomeShellState extends State<ClienteHomeShell> {
  late final SolicitacoesController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = SolicitacoesController(
      listarSolicitacoes: ListarSolicitacoesCliente(widget.repository),
      buscarSolicitacao: BuscarSolicitacao(widget.repository),
      criarSolicitacao: CriarSolicitacao(widget.repository),
      atualizarStatusSolicitacao: AtualizarStatusSolicitacao(widget.repository),
      listarPropostas: ListarPropostasSolicitacao(widget.repository),
      clienteId: AppConfig.clienteId,
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SolicitacoesScreen(controller: _controller),
      StatusOverviewScreen(controller: _controller),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova solicitação'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CriarSolicitacaoScreen(controller: _controller),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.view_agenda_outlined),
            selectedIcon: Icon(Icons.view_agenda),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Status',
          ),
        ],
      ),
    );
  }
}
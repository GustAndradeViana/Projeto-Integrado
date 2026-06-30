import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../controllers/solicitacoes_controller.dart';
import 'criar_solicitacao_screen.dart';
import 'solicitacoes_screen.dart';
import 'status_overview_screen.dart';

class ClienteHomeShell extends StatefulWidget {
  const ClienteHomeShell({
    required this.repository,
    required this.usuario,
    super.key,
  });

  final QuickFreelaRepository repository;
  final Usuario usuario;

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
      aceitarProposta: AceitarPropostaUseCase(widget.repository),
      clienteId: widget.usuario.id,
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
      SolicitacoesScreen(
        controller: _controller,
        repository: widget.repository,
        usuario: widget.usuario,
      ),
      StatusOverviewScreen(
        controller: _controller,
        repository: widget.repository,
        usuario: widget.usuario,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova solicitação'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CriarSolicitacaoScreen(
              controller: _controller,
              clienteId: widget.usuario.id,
              repository: widget.repository,
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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
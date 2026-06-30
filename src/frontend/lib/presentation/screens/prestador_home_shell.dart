import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../controllers/prestador_controller.dart';
import 'prestador_demandas_screen.dart';
import 'prestador_propostas_screen.dart';

class PrestadorHomeShell extends StatefulWidget {
  const PrestadorHomeShell({
    required this.repository,
    required this.usuario,
    super.key,
  });

  final QuickFreelaRepository repository;
  final Usuario usuario;

  @override
  State<PrestadorHomeShell> createState() => _PrestadorHomeShellState();
}

class _PrestadorHomeShellState extends State<PrestadorHomeShell> {
  late final PrestadorController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PrestadorController(
      listarSolicitacoesAbertas: ListarSolicitacoesAbertas(widget.repository),
      buscarSolicitacao: BuscarSolicitacao(widget.repository),
      listarPropostas: ListarPropostasSolicitacao(widget.repository),
      criarProposta: CriarPropostaUseCase(widget.repository),
      listarPropostasPrestador: ListarPropostasPrestador(widget.repository),
      prestadorId: widget.usuario.id,
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
      PrestadorDemandasScreen(
        controller: _controller,
        repository: widget.repository,
        usuario: widget.usuario,
      ),
      PrestadorPropostasScreen(
        controller: _controller,
        repository: widget.repository,
        usuario: widget.usuario,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Demandas',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Minhas propostas',
          ),
        ],
      ),
    );
  }
}
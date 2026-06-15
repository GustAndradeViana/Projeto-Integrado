import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../domain/entities/criar_solicitacao_input.dart';
import '../../domain/entities/proposta.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/usecases/atualizar_status_solicitacao.dart';
import '../../domain/usecases/buscar_solicitacao.dart';
import '../../domain/usecases/criar_solicitacao.dart';
import '../../domain/usecases/listar_propostas_solicitacao.dart';
import '../../domain/usecases/listar_solicitacoes_cliente.dart';

class SolicitacoesController extends ChangeNotifier {
  SolicitacoesController({
    required this.listarSolicitacoes,
    required this.buscarSolicitacao,
    required this.criarSolicitacao,
    required this.atualizarStatusSolicitacao,
    required this.listarPropostas,
    this.clienteId = AppConfig.clienteId,
  });

  final ListarSolicitacoesCliente listarSolicitacoes;
  final BuscarSolicitacao buscarSolicitacao;
  final CriarSolicitacao criarSolicitacao;
  final AtualizarStatusSolicitacao atualizarStatusSolicitacao;
  final ListarPropostasSolicitacao listarPropostas;
  final int clienteId;

  final List<Solicitacao> _solicitacoes = [];
  final Map<int, List<Proposta>> _propostasPorSolicitacao = {};

  Timer? _pollingTimer;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSync;

  List<Solicitacao> get solicitacoes => List.unmodifiable(_solicitacoes);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSync => _lastSync;

  List<Proposta> propostasDaSolicitacao(int solicitacaoId) {
    return List.unmodifiable(_propostasPorSolicitacao[solicitacaoId] ?? []);
  }

  Solicitacao? findById(int solicitacaoId) {
    for (final solicitacao in _solicitacoes) {
      if (solicitacao.id == solicitacaoId) {
        return solicitacao;
      }
    }
    return null;
  }

  int countByStatus(String status) {
    return _solicitacoes.where((item) => item.status == status).length;
  }

  Future<void> start() async {
    await refresh();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: AppConfig.pollingSeconds),
      (_) => refresh(silent: true),
    );
  }

  Future<void> refresh({bool silent = false}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    if (!silent) {
      _isLoading = _solicitacoes.isEmpty;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await listarSolicitacoes(clienteId);
      _solicitacoes
        ..clear()
        ..addAll(result);
      _lastSync = DateTime.now();
      _errorMessage = null;
      await _refreshLoadedProposals();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<Solicitacao> create(CriarSolicitacaoInput input) async {
    final created = await criarSolicitacao(input);
    _solicitacoes.insert(0, created);
    _lastSync = DateTime.now();
    notifyListeners();
    return created;
  }

  Future<void> loadDetails(int solicitacaoId) async {
    try {
      final solicitacao = await buscarSolicitacao(solicitacaoId);
      _replaceSolicitacao(solicitacao);
      _propostasPorSolicitacao[solicitacaoId] =
          await listarPropostas(solicitacaoId);
      _lastSync = DateTime.now();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateStatus(int solicitacaoId, String status) async {
    final updated = await atualizarStatusSolicitacao(solicitacaoId, status);
    _replaceSolicitacao(updated);
    _lastSync = DateTime.now();
    notifyListeners();
  }

  void _replaceSolicitacao(Solicitacao solicitacao) {
    final index = _solicitacoes.indexWhere((item) => item.id == solicitacao.id);
    if (index == -1) {
      _solicitacoes.insert(0, solicitacao);
    } else {
      _solicitacoes[index] = solicitacao;
    }
  }

  Future<void> _refreshLoadedProposals() async {
    final ids = _propostasPorSolicitacao.keys.toList();
    for (final id in ids) {
      _propostasPorSolicitacao[id] = await listarPropostas(id);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

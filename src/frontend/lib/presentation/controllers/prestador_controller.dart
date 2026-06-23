import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/proposta.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/usecases/usecases.dart';

class PrestadorController extends ChangeNotifier {
  PrestadorController({
    required this.listarSolicitacoesAbertas,
    required this.buscarSolicitacao,
    required this.listarPropostas,
    required this.criarProposta,
    required this.listarPropostasPrestador,
    required this.prestadorId,
  });

  final ListarSolicitacoesAbertas listarSolicitacoesAbertas;
  final BuscarSolicitacao buscarSolicitacao;
  final ListarPropostasSolicitacao listarPropostas;
  final CriarPropostaUseCase criarProposta;
  final ListarPropostasPrestador listarPropostasPrestador;
  final int prestadorId;

  final List<Solicitacao> _solicitacoes = [];
  final Map<int, List<Proposta>> _propostasPorSolicitacao = {};
  List<Proposta> _minhasPropostas = [];

  Timer? _pollingTimer;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastSync;

  List<Solicitacao> get solicitacoes => List.unmodifiable(_solicitacoes);
  List<Proposta> get minhasPropostas => List.unmodifiable(_minhasPropostas);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSync => _lastSync;

  List<Proposta> propostasDaSolicitacao(int solicitacaoId) {
    return List.unmodifiable(_propostasPorSolicitacao[solicitacaoId] ?? []);
  }

  Solicitacao? findById(int solicitacaoId) {
    for (final s in _solicitacoes) {
      if (s.id == solicitacaoId) return s;
    }
    return null;
  }

  bool jaMandouProposta(int solicitacaoId) {
    return _minhasPropostas.any((p) => p.solicitacaoId == solicitacaoId);
  }

  Proposta? minhaProposta(int solicitacaoId) {
    try {
      return _minhasPropostas.firstWhere((p) => p.solicitacaoId == solicitacaoId);
    } catch (_) {
      return null;
    }
  }

  Future<void> start() async {
    await refresh();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => refresh(silent: true),
    );
  }

  Future<void> refresh({bool silent = false}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    if (!silent) {
      _isLoading = _solicitacoes.isEmpty;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        listarSolicitacoesAbertas(),
        listarPropostasPrestador(prestadorId),
      ]);
      _solicitacoes
        ..clear()
        ..addAll(results[0] as List<Solicitacao>);
      _minhasPropostas = results[1] as List<Proposta>;
      _lastSync = DateTime.now();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadDetails(int solicitacaoId) async {
    try {
      final solicitacao = await buscarSolicitacao(solicitacaoId);
      final index = _solicitacoes.indexWhere((s) => s.id == solicitacaoId);
      if (index >= 0) {
        _solicitacoes[index] = solicitacao;
      }
      _propostasPorSolicitacao[solicitacaoId] = await listarPropostas(solicitacaoId);
      _lastSync = DateTime.now();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<Proposta> enviarProposta({
    required int solicitacaoId,
    required double valor,
    required int prazoDias,
    required String mensagem,
  }) async {
    final proposta = await criarProposta(
      solicitacaoId: solicitacaoId,
      prestadorId: prestadorId,
      valor: valor,
      prazoDias: prazoDias,
      mensagem: mensagem,
    );
    _minhasPropostas.add(proposta);
    notifyListeners();
    return proposta;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
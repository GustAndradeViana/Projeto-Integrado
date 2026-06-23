import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/mensagem.dart';
import '../../domain/usecases/usecases.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required this.listarMensagens,
    required this.enviarMensagem,
    required this.solicitacaoId,
    required this.usuarioId,
  });

  final ListarMensagensUseCase listarMensagens;
  final EnviarMensagemUseCase enviarMensagem;
  final int solicitacaoId;
  final int usuarioId;

  final List<Mensagem> _mensagens = [];
  Timer? _pollingTimer;
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<Mensagem> get mensagens => List.unmodifiable(_mensagens);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  int get _lastId => _mensagens.isEmpty ? 0 : _mensagens.last.id;

  Future<void> start() async {
    _isLoading = true;
    notifyListeners();
    await _fetch(sinceId: 0);
    _isLoading = false;
    notifyListeners();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetch(sinceId: _lastId));
  }

  Future<void> _fetch({required int sinceId}) async {
    try {
      final novas = await listarMensagens(solicitacaoId, sinceId: sinceId);
      if (novas.isNotEmpty) {
        _mensagens.addAll(novas);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> enviar(String conteudo) async {
    if (conteudo.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();
    try {
      final msg = await enviarMensagem(solicitacaoId, usuarioId, conteudo.trim());
      _mensagens.add(msg);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
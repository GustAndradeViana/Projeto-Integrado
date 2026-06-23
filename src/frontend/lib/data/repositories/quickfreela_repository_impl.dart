import '../../domain/entities/auth_result.dart';
import '../../domain/entities/criar_solicitacao_input.dart';
import '../../domain/entities/mensagem.dart';
import '../../domain/entities/proposta.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../datasources/quickfreela_api_client.dart';
import '../models/mensagem_model.dart';
import '../models/proposta_model.dart';
import '../models/solicitacao_model.dart';
import '../models/usuario_model.dart';

class QuickFreelaRepositoryImpl implements QuickFreelaRepository {
  QuickFreelaRepositoryImpl(this._apiClient);
  final QuickFreelaApiClient _apiClient;

  @override
  Future<AuthResult> login(String email, String senha) async {
    final response = await _apiClient.post('/auth/login', {'email': email, 'senha': senha});
    final map = response as Map<String, dynamic>;
    final token = map['token'] as String;
    final usuario = UsuarioModel.fromJson(map['usuario'] as Map<String, dynamic>);
    _apiClient.setToken(token);
    return AuthResult(token: token, usuario: usuario);
  }

  @override
  Future<AuthResult> registrar(String nome, String email, String senha, String perfil) async {
    final response = await _apiClient.post('/auth/register', {
      'nome': nome,
      'email': email,
      'senha': senha,
      'perfil': perfil,
    });
    final usuario = UsuarioModel.fromJson(response as Map<String, dynamic>);
    final loginResult = await login(email, senha);
    return loginResult;
  }

  @override
  Future<List<Solicitacao>> listarSolicitacoesDoCliente(int clienteId) async {
    final response = await _apiClient.get('/solicitacoes', query: {'cliente_id': clienteId.toString()});
    return (response as List<dynamic>)
        .map((item) => SolicitacaoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Solicitacao>> listarSolicitacoesAbertas() async {
    final response = await _apiClient.get('/solicitacoes', query: {'status': 'aberta'});
    return (response as List<dynamic>)
        .map((item) => SolicitacaoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Solicitacao> buscarSolicitacao(int id) async {
    final response = await _apiClient.get('/solicitacoes/$id');
    return SolicitacaoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Solicitacao> criarSolicitacao(CriarSolicitacaoInput input) async {
    final response = await _apiClient.post('/solicitacoes', input.toJson());
    return SolicitacaoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Solicitacao> atualizarStatus(int solicitacaoId, String status) async {
    final response = await _apiClient.patch('/solicitacoes/$solicitacaoId/status', {'status': status});
    return SolicitacaoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<Proposta>> listarPropostas(int solicitacaoId) async {
    final response = await _apiClient.get('/propostas', query: {'solicitacao_id': solicitacaoId.toString()});
    return (response as List<dynamic>)
        .map((item) => PropostaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Proposta>> listarPropostasDoPrestador(int prestadorId) async {
    final response = await _apiClient.get('/propostas', query: {'prestador_id': prestadorId.toString()});
    return (response as List<dynamic>)
        .map((item) => PropostaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Proposta> criarProposta({
    required int solicitacaoId,
    required int prestadorId,
    required double valor,
    required int prazoDias,
    required String mensagem,
  }) async {
    final response = await _apiClient.post('/propostas', {
      'solicitacao_id': solicitacaoId,
      'prestador_id': prestadorId,
      'valor': valor,
      'prazo_dias': prazoDias,
      'mensagem': mensagem,
    });
    return PropostaModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> aceitarProposta(int solicitacaoId, int propostaId, int clienteId) async {
    final response = await _apiClient.post(
      '/solicitacoes/$solicitacaoId/propostas/$propostaId/aceitar',
      {'cliente_id': clienteId},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Mensagem>> listarMensagens(int solicitacaoId, {int sinceId = 0}) async {
    final response = await _apiClient.get(
      '/solicitacoes/$solicitacaoId/mensagens',
      query: sinceId > 0 ? {'since_id': sinceId.toString()} : null,
    );
    return (response as List<dynamic>)
        .map((item) => MensagemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Mensagem> enviarMensagem(int solicitacaoId, int remetenteId, String conteudo) async {
    final response = await _apiClient.post('/solicitacoes/$solicitacaoId/mensagens', {
      'remetente_id': remetenteId,
      'conteudo': conteudo,
    });
    return MensagemModel.fromJson(response as Map<String, dynamic>);
  }
}
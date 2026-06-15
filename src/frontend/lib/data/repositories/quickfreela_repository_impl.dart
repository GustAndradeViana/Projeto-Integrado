import '../../domain/entities/criar_solicitacao_input.dart';
import '../../domain/entities/proposta.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/repositories/quickfreela_repository.dart';
import '../datasources/quickfreela_api_client.dart';
import '../models/proposta_model.dart';
import '../models/solicitacao_model.dart';

class QuickFreelaRepositoryImpl implements QuickFreelaRepository {
  QuickFreelaRepositoryImpl(this._apiClient);

  final QuickFreelaApiClient _apiClient;

  @override
  Future<List<Solicitacao>> listarSolicitacoesDoCliente(int clienteId) async {
    final response = await _apiClient.get(
      '/solicitacoes',
      query: {'cliente_id': clienteId.toString()},
    );
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
    final response = await _apiClient.patch(
      '/solicitacoes/$solicitacaoId/status',
      {'status': status},
    );
    return SolicitacaoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<Proposta>> listarPropostas(int solicitacaoId) async {
    final response = await _apiClient.get(
      '/propostas',
      query: {'solicitacao_id': solicitacaoId.toString()},
    );
    return (response as List<dynamic>)
        .map((item) => PropostaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

import '../entities/proposta.dart';
import '../repositories/quickfreela_repository.dart';

class ListarPropostasSolicitacao {
  const ListarPropostasSolicitacao(this._repository);

  final QuickFreelaRepository _repository;

  Future<List<Proposta>> call(int solicitacaoId) {
    return _repository.listarPropostas(solicitacaoId);
  }
}

import '../entities/solicitacao.dart';
import '../repositories/quickfreela_repository.dart';

class AtualizarStatusSolicitacao {
  const AtualizarStatusSolicitacao(this._repository);

  final QuickFreelaRepository _repository;

  Future<Solicitacao> call(int solicitacaoId, String status) {
    return _repository.atualizarStatus(solicitacaoId, status);
  }
}

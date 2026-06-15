import '../entities/solicitacao.dart';
import '../repositories/quickfreela_repository.dart';

class BuscarSolicitacao {
  const BuscarSolicitacao(this._repository);

  final QuickFreelaRepository _repository;

  Future<Solicitacao> call(int solicitacaoId) {
    return _repository.buscarSolicitacao(solicitacaoId);
  }
}

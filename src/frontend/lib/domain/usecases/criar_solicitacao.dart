import '../entities/criar_solicitacao_input.dart';
import '../entities/solicitacao.dart';
import '../repositories/quickfreela_repository.dart';

class CriarSolicitacao {
  const CriarSolicitacao(this._repository);

  final QuickFreelaRepository _repository;

  Future<Solicitacao> call(CriarSolicitacaoInput input) {
    return _repository.criarSolicitacao(input);
  }
}

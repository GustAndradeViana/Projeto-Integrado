import '../entities/solicitacao.dart';
import '../repositories/quickfreela_repository.dart';

class ListarSolicitacoesCliente {
  const ListarSolicitacoesCliente(this._repository);

  final QuickFreelaRepository _repository;

  Future<List<Solicitacao>> call(int clienteId) {
    return _repository.listarSolicitacoesDoCliente(clienteId);
  }
}

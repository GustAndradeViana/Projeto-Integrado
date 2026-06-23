import '../entities/auth_result.dart';
import '../entities/criar_solicitacao_input.dart';
import '../entities/mensagem.dart';
import '../entities/proposta.dart';
import '../entities/solicitacao.dart';
import '../repositories/quickfreela_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<AuthResult> call(String email, String senha) => _repository.login(email, senha);
}

class RegistrarUseCase {
  const RegistrarUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<AuthResult> call(String nome, String email, String senha, String perfil) =>
      _repository.registrar(nome, email, senha, perfil);
}

class ListarSolicitacoesCliente {
  const ListarSolicitacoesCliente(this._repository);
  final QuickFreelaRepository _repository;
  Future<List<Solicitacao>> call(int clienteId) =>
      _repository.listarSolicitacoesDoCliente(clienteId);
}

class ListarSolicitacoesAbertas {
  const ListarSolicitacoesAbertas(this._repository);
  final QuickFreelaRepository _repository;
  Future<List<Solicitacao>> call() => _repository.listarSolicitacoesAbertas();
}

class BuscarSolicitacao {
  const BuscarSolicitacao(this._repository);
  final QuickFreelaRepository _repository;
  Future<Solicitacao> call(int solicitacaoId) => _repository.buscarSolicitacao(solicitacaoId);
}

class CriarSolicitacao {
  const CriarSolicitacao(this._repository);
  final QuickFreelaRepository _repository;
  Future<Solicitacao> call(CriarSolicitacaoInput input) => _repository.criarSolicitacao(input);
}

class AtualizarStatusSolicitacao {
  const AtualizarStatusSolicitacao(this._repository);
  final QuickFreelaRepository _repository;
  Future<Solicitacao> call(int solicitacaoId, String status) =>
      _repository.atualizarStatus(solicitacaoId, status);
}

class ListarPropostasSolicitacao {
  const ListarPropostasSolicitacao(this._repository);
  final QuickFreelaRepository _repository;
  Future<List<Proposta>> call(int solicitacaoId) => _repository.listarPropostas(solicitacaoId);
}

class ListarPropostasPrestador {
  const ListarPropostasPrestador(this._repository);
  final QuickFreelaRepository _repository;
  Future<List<Proposta>> call(int prestadorId) =>
      _repository.listarPropostasDoPrestador(prestadorId);
}

class CriarPropostaUseCase {
  const CriarPropostaUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<Proposta> call({
    required int solicitacaoId,
    required int prestadorId,
    required double valor,
    required int prazoDias,
    required String mensagem,
  }) =>
      _repository.criarProposta(
        solicitacaoId: solicitacaoId,
        prestadorId: prestadorId,
        valor: valor,
        prazoDias: prazoDias,
        mensagem: mensagem,
      );
}

class AceitarPropostaUseCase {
  const AceitarPropostaUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<Map<String, dynamic>> call(int solicitacaoId, int propostaId, int clienteId) =>
      _repository.aceitarProposta(solicitacaoId, propostaId, clienteId);
}

class ListarMensagensUseCase {
  const ListarMensagensUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<List<Mensagem>> call(int solicitacaoId, {int sinceId = 0}) =>
      _repository.listarMensagens(solicitacaoId, sinceId: sinceId);
}

class EnviarMensagemUseCase {
  const EnviarMensagemUseCase(this._repository);
  final QuickFreelaRepository _repository;
  Future<Mensagem> call(int solicitacaoId, int remetenteId, String conteudo) =>
      _repository.enviarMensagem(solicitacaoId, remetenteId, conteudo);
}
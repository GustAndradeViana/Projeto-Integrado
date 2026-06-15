import '../entities/criar_solicitacao_input.dart';
import '../entities/proposta.dart';
import '../entities/solicitacao.dart';

abstract class QuickFreelaRepository {
  Future<List<Solicitacao>> listarSolicitacoesDoCliente(int clienteId);
  Future<Solicitacao> buscarSolicitacao(int id);
  Future<Solicitacao> criarSolicitacao(CriarSolicitacaoInput input);
  Future<Solicitacao> atualizarStatus(int solicitacaoId, String status);
  Future<List<Proposta>> listarPropostas(int solicitacaoId);
}

import '../entities/auth_result.dart';
import '../entities/criar_solicitacao_input.dart';
import '../entities/mensagem.dart';
import '../entities/proposta.dart';
import '../entities/solicitacao.dart';
import '../entities/usuario.dart';

abstract class QuickFreelaRepository {
  Future<AuthResult> login(String email, String senha);
  Future<AuthResult> registrar(String nome, String email, String senha, String perfil);

  Future<List<Solicitacao>> listarSolicitacoesDoCliente(int clienteId);
  Future<List<Solicitacao>> listarSolicitacoesAbertas();
  Future<Solicitacao> buscarSolicitacao(int id);
  Future<Solicitacao> criarSolicitacao(CriarSolicitacaoInput input);
  Future<Solicitacao> atualizarStatus(int solicitacaoId, String status);

  Future<List<Proposta>> listarPropostas(int solicitacaoId);
  Future<List<Proposta>> listarPropostasDoPrestador(int prestadorId);
  Future<Proposta> criarProposta({
    required int solicitacaoId,
    required int prestadorId,
    required double valor,
    required int prazoDias,
    required String mensagem,
  });
  Future<Map<String, dynamic>> aceitarProposta(int solicitacaoId, int propostaId, int clienteId);

  Future<List<Mensagem>> listarMensagens(int solicitacaoId, {int sinceId = 0});
  Future<Mensagem> enviarMensagem(int solicitacaoId, int remetenteId, String conteudo);
}
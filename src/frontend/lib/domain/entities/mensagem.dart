class Mensagem {
  const Mensagem({
    required this.id,
    required this.solicitacaoId,
    required this.remetenteId,
    required this.conteudo,
    this.remetenteNome,
    this.remetentePerfil,
    this.criadoEm,
  });

  final int id;
  final int solicitacaoId;
  final int remetenteId;
  final String conteudo;
  final String? remetenteNome;
  final String? remetentePerfil;
  final String? criadoEm;
}
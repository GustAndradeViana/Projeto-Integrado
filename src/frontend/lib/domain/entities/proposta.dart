class Proposta {
  const Proposta({
    required this.id,
    required this.solicitacaoId,
    required this.prestadorId,
    required this.valor,
    required this.prazoDias,
    required this.mensagem,
    required this.status,
    this.prestadorNome,
    this.solicitacaoTitulo,
    this.criadoEm,
    this.atualizadoEm,
  });

  final int id;
  final int solicitacaoId;
  final int prestadorId;
  final double valor;
  final int prazoDias;
  final String mensagem;
  final String status;
  final String? prestadorNome;
  final String? solicitacaoTitulo;
  final String? criadoEm;
  final String? atualizadoEm;

  bool get isPendente => status == 'pendente';
  bool get isAceita => status == 'aceita';

  String get statusLabel {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'aceita':
        return 'Aceita';
      case 'recusada':
        return 'Recusada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }
}
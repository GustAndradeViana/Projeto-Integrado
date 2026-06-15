class Solicitacao {
  const Solicitacao({
    required this.id,
    required this.clienteId,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.orcamento,
    required this.status,
    this.prazoEntrega,
    this.prestadorId,
    this.propostaAceitaId,
    this.clienteNome,
    this.prestadorNome,
    this.criadoEm,
    this.atualizadoEm,
  });

  final int id;
  final int clienteId;
  final String titulo;
  final String descricao;
  final String categoria;
  final double orcamento;
  final String status;
  final String? prazoEntrega;
  final int? prestadorId;
  final int? propostaAceitaId;
  final String? clienteNome;
  final String? prestadorNome;
  final String? criadoEm;
  final String? atualizadoEm;

  bool get isAberta => status == 'aberta';
  bool get isEmAndamento => status == 'em_andamento';
  bool get isConcluida => status == 'concluida';
  bool get isCancelada => status == 'cancelada';

  String get statusLabel {
    switch (status) {
      case 'aberta':
        return 'Aberta';
      case 'em_andamento':
        return 'Em andamento';
      case 'concluida':
        return 'Concluida';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }
}

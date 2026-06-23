class CriarSolicitacaoInput {
  const CriarSolicitacaoInput({
    required this.clienteId,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.orcamento,
    this.prazoEntrega,
  });

  final int clienteId;
  final String titulo;
  final String descricao;
  final String categoria;
  final double orcamento;
  final String? prazoEntrega;

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'orcamento': orcamento,
      if (prazoEntrega != null && prazoEntrega!.isNotEmpty) 'prazo_entrega': prazoEntrega,
    };
  }
}
import '../../domain/entities/solicitacao.dart';

class SolicitacaoModel extends Solicitacao {
  const SolicitacaoModel({
    required super.id,
    required super.clienteId,
    required super.titulo,
    required super.descricao,
    required super.categoria,
    required super.orcamento,
    required super.status,
    super.prazoEntrega,
    super.prestadorId,
    super.propostaAceitaId,
    super.clienteNome,
    super.prestadorNome,
    super.criadoEm,
    super.atualizadoEm,
  });

  factory SolicitacaoModel.fromJson(Map<String, dynamic> json) {
    return SolicitacaoModel(
      id: _asInt(json['id']),
      clienteId: _asInt(json['cliente_id']),
      titulo: json['titulo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? 'geral',
      orcamento: _asDouble(json['orcamento']),
      status: json['status']?.toString() ?? 'aberta',
      prazoEntrega: json['prazo_entrega']?.toString(),
      prestadorId: _asNullableInt(json['prestador_id']),
      propostaAceitaId: _asNullableInt(json['proposta_aceita_id']),
      clienteNome: json['cliente_nome']?.toString(),
      prestadorNome: json['prestador_nome']?.toString(),
      criadoEm: json['criado_em']?.toString(),
      atualizadoEm: json['atualizado_em']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  return _asInt(value);
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
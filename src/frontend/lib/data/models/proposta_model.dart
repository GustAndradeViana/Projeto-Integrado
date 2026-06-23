import '../../domain/entities/proposta.dart';

class PropostaModel extends Proposta {
  const PropostaModel({
    required super.id,
    required super.solicitacaoId,
    required super.prestadorId,
    required super.valor,
    required super.prazoDias,
    required super.mensagem,
    required super.status,
    super.prestadorNome,
    super.solicitacaoTitulo,
    super.criadoEm,
    super.atualizadoEm,
  });

  factory PropostaModel.fromJson(Map<String, dynamic> json) {
    return PropostaModel(
      id: _asInt(json['id']),
      solicitacaoId: _asInt(json['solicitacao_id']),
      prestadorId: _asInt(json['prestador_id']),
      valor: _asDouble(json['valor']),
      prazoDias: _asInt(json['prazo_dias']),
      mensagem: json['mensagem']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pendente',
      prestadorNome: json['prestador_nome']?.toString(),
      solicitacaoTitulo: json['solicitacao_titulo']?.toString(),
      criadoEm: json['criado_em']?.toString(),
      atualizadoEm: json['atualizado_em']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
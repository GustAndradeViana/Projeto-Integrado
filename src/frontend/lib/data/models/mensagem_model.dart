import '../../domain/entities/mensagem.dart';

class MensagemModel extends Mensagem {
  const MensagemModel({
    required super.id,
    required super.solicitacaoId,
    required super.remetenteId,
    required super.conteudo,
    super.remetenteNome,
    super.remetentePerfil,
    super.criadoEm,
  });

  factory MensagemModel.fromJson(Map<String, dynamic> json) {
    return MensagemModel(
      id: _asInt(json['id']),
      solicitacaoId: _asInt(json['solicitacao_id']),
      remetenteId: _asInt(json['remetente_id']),
      conteudo: json['conteudo']?.toString() ?? '',
      remetenteNome: json['remetente_nome']?.toString(),
      remetentePerfil: json['remetente_perfil']?.toString(),
      criadoEm: json['criado_em']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
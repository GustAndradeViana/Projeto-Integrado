import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.perfil,
    super.criadoEm,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: _asInt(json['id']),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      perfil: json['perfil']?.toString() ?? 'cliente',
      criadoEm: json['criado_em']?.toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
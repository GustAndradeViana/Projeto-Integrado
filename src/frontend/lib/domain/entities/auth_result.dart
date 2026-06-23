import 'usuario.dart';

class AuthResult {
  const AuthResult({required this.token, required this.usuario});
  final String token;
  final Usuario usuario;
}
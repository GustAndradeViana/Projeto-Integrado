import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/usecases.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.loginUseCase, required this.registrarUseCase});

  final LoginUseCase loginUseCase;
  final RegistrarUseCase registrarUseCase;

  Usuario? _usuario;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  Usuario? get usuario => _usuario;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _usuario != null;

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await loginUseCase(email, senha);
      _usuario = result.usuario;
      _token = result.token;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrar(String nome, String email, String senha, String perfil) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await registrarUseCase(nome, email, senha, perfil);
      _usuario = result.usuario;
      _token = result.token;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _usuario = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }
}
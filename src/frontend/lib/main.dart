import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/quickfreela_api_client.dart';
import 'data/repositories/quickfreela_repository_impl.dart';
import 'domain/entities/usuario.dart';
import 'domain/repositories/quickfreela_repository.dart';
import 'domain/usecases/usecases.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/cliente_home_shell.dart';
import 'presentation/screens/prestador_home_shell.dart';

void main() {
  final apiClient = QuickFreelaApiClient(baseUrl: AppConfig.apiBaseUrl);
  final repository = QuickFreelaRepositoryImpl(apiClient);
  runApp(QuickFreelaApp(repository: repository));
}

class QuickFreelaApp extends StatelessWidget {
  const QuickFreelaApp({required this.repository, super.key});
  final QuickFreelaRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickFreela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _AuthGate(repository: repository),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.repository});
  final QuickFreelaRepository repository;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      loginUseCase: LoginUseCase(widget.repository),
      registrarUseCase: RegistrarUseCase(widget.repository),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        if (!_authController.isLoggedIn) {
          return AuthScreen(controller: _authController);
        }
        return _HomeRouter(
          repository: widget.repository,
          usuario: _authController.usuario!,
          onLogout: _authController.logout,
        );
      },
    );
  }
}

class _HomeRouter extends StatelessWidget {
  const _HomeRouter({
    required this.repository,
    required this.usuario,
    required this.onLogout,
  });

  final QuickFreelaRepository repository;
  final Usuario usuario;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (usuario.isCliente) {
      return ClienteHomeShell(repository: repository, usuario: usuario);
    }
    return PrestadorHomeShell(repository: repository, usuario: usuario);
  }
}
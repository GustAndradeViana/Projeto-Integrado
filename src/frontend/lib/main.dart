import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/quickfreela_api_client.dart';
import 'data/repositories/quickfreela_repository_impl.dart';
import 'domain/repositories/quickfreela_repository.dart';
import 'presentation/screens/cliente_home_shell.dart';

void main() {
  final repository = QuickFreelaRepositoryImpl(
    QuickFreelaApiClient(baseUrl: AppConfig.apiBaseUrl),
  );

  runApp(QuickFreelaClienteApp(repository: repository));
}

class QuickFreelaClienteApp extends StatelessWidget {
  const QuickFreelaClienteApp({required this.repository, super.key});

  final QuickFreelaRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickFreela Cliente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: ClienteHomeShell(repository: repository),
    );
  }
}

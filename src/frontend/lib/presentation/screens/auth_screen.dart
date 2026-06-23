import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.controller, super.key});
  final AuthController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginSenhaController = TextEditingController();
  final _regNomeController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regSenhaController = TextEditingController();
  String _perfil = 'cliente';
  bool _obscureLogin = true;
  bool _obscureReg = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginSenhaController.dispose();
    _regNomeController.dispose();
    _regEmailController.dispose();
    _regSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              children: [
                const _Logo(),
                const SizedBox(height: 36),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF0F172A),
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Entrar'),
                      Tab(text: 'Criar conta'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 420,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _LoginForm(
                        formKey: _loginFormKey,
                        emailController: _loginEmailController,
                        senhaController: _loginSenhaController,
                        obscure: _obscureLogin,
                        onToggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
                        isLoading: widget.controller.isLoading,
                        onSubmit: _doLogin,
                      ),
                      _RegisterForm(
                        formKey: _registerFormKey,
                        nomeController: _regNomeController,
                        emailController: _regEmailController,
                        senhaController: _regSenhaController,
                        perfil: _perfil,
                        obscure: _obscureReg,
                        onToggleObscure: () => setState(() => _obscureReg = !_obscureReg),
                        onPerfilChanged: (v) => setState(() => _perfil = v ?? 'cliente'),
                        isLoading: widget.controller.isLoading,
                        onSubmit: _doRegister,
                      ),
                    ],
                  ),
                ),
                if (widget.controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.controller.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _doLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await widget.controller.login(
      _loginEmailController.text.trim(),
      _loginSenhaController.text,
    );
  }

  Future<void> _doRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    await widget.controller.registrar(
      _regNomeController.text.trim(),
      _regEmailController.text.trim(),
      _regSenhaController.text,
      _perfil,
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'QuickFreela',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF0F172A),
                letterSpacing: -1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Conecte-se com os melhores profissionais',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.senhaController,
    required this.obscure,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: senhaController,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const LinearProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
            ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nomeController,
    required this.emailController,
    required this.senhaController,
    required this.perfil,
    required this.obscure,
    required this.onToggleObscure,
    required this.onPerfilChanged,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final String perfil;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String?> onPerfilChanged;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nomeController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: senhaController,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: perfil,
            decoration: const InputDecoration(
              labelText: 'Perfil',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'cliente', child: Text('Cliente — Preciso de serviços')),
              DropdownMenuItem(
                  value: 'prestador', child: Text('Prestador — Ofereço serviços')),
            ],
            onChanged: onPerfilChanged,
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const LinearProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Criar conta'),
            ),
        ],
      ),
    );
  }
}
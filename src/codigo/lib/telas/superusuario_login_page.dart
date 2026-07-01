import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';
import '../domain/empresa_repository.dart';
import '../funcionalidades/superusuario.dart';
import 'superusuario_painel_page.dart';

/// Login separado do fluxo de Cliente/Empresa, usado só pela equipe do
/// projeto para acessar o painel de superusuário (conceder permissão de
/// cadastrar mais restaurantes para uma empresa específica).
///
/// As credenciais continuam sendo contas normais do Firebase Authentication
/// — a diferença é que, depois de autenticado, só passa quem tiver o e-mail
/// na lista de [Superusuario.emailsAutorizados].
class SuperusuarioLoginPage extends StatefulWidget {
  final AuthRepository authRepo;
  final EmpresaRepository empresaRepo;

  const SuperusuarioLoginPage({
    super.key,
    required this.authRepo,
    required this.empresaRepo,
  });

  @override
  State<SuperusuarioLoginPage> createState() => _SuperusuarioLoginPageState();
}

class _SuperusuarioLoginPageState extends State<SuperusuarioLoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.authRepo.login(email, senha);

      if (!Superusuario.ehSuperusuario(email)) {
        // Autenticou, mas essa conta não tem permissão de superusuário:
        // desloga de novo pra não deixar sessão pendurada.
        await widget.authRepo.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta conta não tem permissão de superusuário'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuperusuarioPainelPage(
            empresaRepo: widget.empresaRepo,
            authRepo: widget.authRepo,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Acesso restrito', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.admin_panel_settings_outlined,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Login de superusuário',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Área restrita à equipe do projeto',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _isLoading ? null : _entrar(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _entrar,
                  child: _isLoading
                      ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                      : const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

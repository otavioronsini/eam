import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'empresa_page.dart';
import 'cliente_page.dart';
import '../domain/cliente_repository.dart';
import '../domain/estabelecimento_repository.dart';
import '../domain/auth_repository.dart';
import '../funcionalidades/cliente.dart';

class HomePage extends StatefulWidget {
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;
  final AuthRepository authRepo;

  const HomePage({
    super.key,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
    required this.authRepo,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  String _tipoUsuario = 'cliente';

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submeterAuth() async {
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
      String uid;
      if (_isLogin) {
        uid = await widget.authRepo.login(email, senha);
      } else {
        uid = await widget.authRepo.cadastrar(email, senha);

        if (_tipoUsuario == 'cliente') {
          await widget.clienteRepo.insertCliente(Cliente(
            id: uid,
            nome: 'Novo Cliente',
            email: email,
          ));
        }
      }

      if (!mounted) return;
      _acessarPainel(uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _acessarPainel(String uid) async {
    if (_tipoUsuario == 'cliente') {
      Cliente? cliente = await widget.clienteRepo.getCliente(uid);
      if (cliente == null) return;

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ClientePage(
          cliente: cliente,
          clienteRepo: widget.clienteRepo,
          estabelecimentoRepo: widget.estabelecimentoRepo,
        ),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => EmpresaPage(
          estabelecimentoRepo: widget.estabelecimentoRepo,
          empresaId: uid,
        ),
      ));
    }
  }

  Widget _buildBackgroundPattern(double width, double height, {required bool isTop, required Color color}) {
    final random = Random(42);
    final iconsTop = [Icons.stars_outlined, Icons.arrow_downward, Icons.emoji_events_outlined];
    final iconsBottom = [Icons.restaurant_outlined, Icons.local_drink_outlined, Icons.fastfood_outlined, Icons.local_pizza_outlined];
    final icons = isTop ? iconsTop : iconsBottom;
    final posicoes = [
      const Offset(0.1, 0.1), const Offset(0.5, 0.15), const Offset(0.85, 0.05),
      const Offset(0.25, 0.4), const Offset(0.7, 0.45), const Offset(0.9, 0.35),
      const Offset(0.15, 0.75), const Offset(0.5, 0.85), const Offset(0.8, 0.7)
    ];

    return SizedBox(
      width: width, height: height,
      child: Stack(
        children: posicoes.map((pos) => Positioned(
          left: width * pos.dx, top: height * pos.dy,
          child: Opacity(
              opacity: 0.08,
              child: Transform.rotate(
                  angle: random.nextDouble() * 2 * pi,
                  child: Icon(icons[random.nextInt(icons.length)], size: 28 + random.nextDouble() * 12, color: color)
              )
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ================= BACKGROUND FIXO =================
          Positioned(
              top: size.height * 0.45, left: 0,
              child: _buildBackgroundPattern(size.width, size.height * 0.55, isTop: false, color: Colors.grey)
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipPath(
              clipper: _TopWaveClipper(),
              child: Container(
                height: size.height * 0.45,
                width: size.width,
                color: theme.colorScheme.primary.withOpacity(0.9),
                child: _buildBackgroundPattern(size.width, size.height * 0.45, isTop: true, color: Colors.white),
              ),
            ),
          ),

          // ================= CONTEÚDO SCROLLÁVEL =================
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bloqueia a área do título para alinhar perfeitamente com os 45% do fundo roxo
                      SizedBox(
                        height: size.height * 0.25,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32, bottom: 24),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: SizedBox(
                              width: size.width - 64,
                              child: FittedBox(
                                fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                                child: Text(
                                    'FIDELIDADE\nAPP',
                                    style: GoogleFonts.nunito(
                                        textStyle: theme.textTheme.displayLarge?.copyWith(
                                            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 70, height: 0.9, letterSpacing: -2.0
                                        )
                                    )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Espaçamento de segurança para o E-mail ficar próximo da divisa, sem tocar nela
                      const SizedBox(height: 200),

                      // ================= FORMULÁRIO =================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey))
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _senhaController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey))
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                onPressed: _isLoading ? null : _submeterAuth,
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(_isLogin ? 'Entrar' : 'Cadastrar', style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _isLogin = !_isLogin),
                              child: Text(_isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Faça login'),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const Text('Cliente'),
                                  selected: _tipoUsuario == 'cliente',
                                  onSelected: (val) => setState(() => _tipoUsuario = 'cliente'),
                                ),
                                const SizedBox(width: 16),
                                ChoiceChip(
                                  label: const Text('Empresa'),
                                  selected: _tipoUsuario == 'empresa',
                                  onSelected: (val) => setState(() => _tipoUsuario = 'empresa'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
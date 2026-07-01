import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'telas/home_page.dart';
import 'domain/firestore_cliente_repository.dart';
import 'domain/firestore_estabelecimento_repository.dart';
import 'domain/firestore_empresa_repository.dart';
import 'domain/firebase_auth_repository.dart';
import 'domain/cliente_repository.dart';
import 'domain/estabelecimento_repository.dart';
import 'domain/empresa_repository.dart';
import 'domain/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final clienteRepo = FirestoreClienteRepository();
  final estabelecimentoRepo = FirestoreEstabelecimentoRepository();
  final empresaRepo = FirestoreEmpresaRepository();
  final authRepo = FirebaseAuthRepository();

  runApp(MyApp(
    clienteRepo: clienteRepo,
    estabelecimentoRepo: estabelecimentoRepo,
    empresaRepo: empresaRepo,
    authRepo: authRepo,
  ));
}

class MyApp extends StatelessWidget {
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;
  final EmpresaRepository empresaRepo;
  final AuthRepository authRepo;

  const MyApp({
    super.key,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
    required this.empresaRepo,
    required this.authRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gruda Aí!',
      debugShowCheckedModeBanner: false,
      // Todas as telas do app foram desenhadas para o tema escuro (fundo
      // 0xFF0F172A, texto branco etc. fixos no código). Deixar o Flutter
      // alternar para o tema claro conforme o sistema (ThemeMode.system)
      // fazia com que os cards (que usam theme.colorScheme.surface, esse
      // sim sensível ao tema) ficassem claros enquanto o texto continuava
      // branco — por isso o texto "sumia" em telas/lugares com fundo claro.
      // Travando em ThemeMode.dark garantimos que o colorScheme resolvido
      // em tempo de execução sempre bate com as cores fixas usadas nas telas.
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF202124),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark, surface: const Color(0xFF303134)),
        useMaterial3: true,
      ),
      home: HomePage(
        clienteRepo: clienteRepo,
        estabelecimentoRepo: estabelecimentoRepo,
        empresaRepo: empresaRepo,
        authRepo: authRepo,
      ),
    );
  }
}
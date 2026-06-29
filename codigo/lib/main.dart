import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'telas/home_page.dart';
import 'domain/firestore_cliente_repository.dart';
import 'domain/firestore_estabelecimento_repository.dart';
import 'domain/firebase_auth_repository.dart';
import 'domain/cliente_repository.dart';
import 'domain/estabelecimento_repository.dart';
import 'domain/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final clienteRepo = FirestoreClienteRepository();
  final estabelecimentoRepo = FirestoreEstabelecimentoRepository();
  final authRepo = FirebaseAuthRepository();

  runApp(MyApp(
    clienteRepo: clienteRepo,
    estabelecimentoRepo: estabelecimentoRepo,
    authRepo: authRepo,
  ));
}

class MyApp extends StatelessWidget {
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;
  final AuthRepository authRepo;

  const MyApp({
    super.key,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
    required this.authRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FidelidadeApp',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
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
        authRepo: authRepo,
      ),
    );
  }
}
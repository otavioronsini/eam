import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> cadastrar(String email, String senha) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return credencial.user!.uid;
  }

  @override
  Future<String> login(String email, String senha) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return credencial.user!.uid;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  String? get usuarioAtualId => _auth.currentUser?.uid;
}
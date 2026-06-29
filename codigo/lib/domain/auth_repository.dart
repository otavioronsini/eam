abstract class AuthRepository {
  Future<String> cadastrar(String email, String senha);
  Future<String> login(String email, String senha);
  Future<void> logout();
  String? get usuarioAtualId;
}
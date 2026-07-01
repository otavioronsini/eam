import '../funcionalidades/cliente.dart';

abstract class ClienteRepository {
  Future<String> insertCliente(Cliente cliente);
  Future<Cliente?> getCliente(String id);
  Future<List<Cliente>> getClientes();
  Future<Cliente?> getFirstCliente();
  Future<void> updateCliente(Cliente cliente);

  // Pontuação
  Future<Map<String, dynamic>> getOrCreatePontos(String clienteId, String estabelecimentoId);
  Future<int> adicionarPontos(String clienteId, String estabelecimentoId, int quantidade);
  Future<bool> resgatarPontos(String clienteId, String estabelecimentoId, int quantidade);
  Future<List<Map<String, dynamic>>> getAllPontosByCliente(String clienteId);
  Future<Map<String, int>> getTotaisGlobais(String clienteId);
}
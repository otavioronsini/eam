import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/recompensa.dart';
import '../funcionalidades/pedido.dart';

abstract class EstabelecimentoRepository {
  Future<String> insertEstabelecimento(Estabelecimento est);
  Future<Estabelecimento?> getEstabelecimento(String id);
  Future<List<Estabelecimento>> getEstabelecimentos();
  Future<List<Estabelecimento>> getEstabelecimentosDaEmpresa(String empresaId);
  Future<Estabelecimento?> getFirstEstabelecimento();
  Future<void> updateEstabelecimento(Estabelecimento est);
  Future<void> deleteEstabelecimento(String id);

  // QR Codes
  Future<void> criarQrCode(String estabelecimentoId, String token, int pontos);
  Future<Map<String, dynamic>?> getQrCode(String token);
  Future<void> marcarQrComoUsado(String token);

  // Recompensas
  Future<String> insertRecompensa(Recompensa rec);
  Future<List<Recompensa>> getRecompensasByEstabelecimento(String estId);
  Future<void> updateRecompensa(Recompensa rec);
  Future<void> deleteRecompensa(String id);

  // Histórico de pedidos (registrado a cada resgate/consumo de pontos)
  Future<void> registrarPedido(Pedido pedido);
  Future<List<Pedido>> getPedidosByEstabelecimento(String estabelecimentoId);
}

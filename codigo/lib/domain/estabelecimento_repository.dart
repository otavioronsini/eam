import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/recompensa.dart';

abstract class EstabelecimentoRepository {
  Future<String> insertEstabelecimento(Estabelecimento est);
  Future<Estabelecimento?> getEstabelecimento(String id);
  Future<List<Estabelecimento>> getEstabelecimentos();
  Future<Estabelecimento?> getFirstEstabelecimento();
  Future<void> updateEstabelecimento(Estabelecimento est);
  Future<void> deleteEstabelecimento(String id);

  // QR Codes
  Future<void> criarQrCode(String estabelecimentoId, String token);
  Future<Map<String, dynamic>?> getQrCode(String token);
  Future<void> marcarQrComoUsado(String token);

  // Recompensas
  Future<String> insertRecompensa(Recompensa rec);
  Future<List<Recompensa>> getRecompensasByEstabelecimento(String estId);
  Future<void> updateRecompensa(Recompensa rec);
  Future<void> deleteRecompensa(String id);
}
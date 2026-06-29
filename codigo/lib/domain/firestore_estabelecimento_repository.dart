import 'package:cloud_firestore/cloud_firestore.dart';
import 'estabelecimento_repository.dart';
import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/recompensa.dart';

class FirestoreEstabelecimentoRepository implements EstabelecimentoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<String> insertEstabelecimento(Estabelecimento est) async {
    final docRef = _db.collection('estabelecimentos').doc();
    final data = est.toMap();
    data['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  @override
  Future<Estabelecimento?> getEstabelecimento(String id) async {
    final doc = await _db.collection('estabelecimentos').doc(id).get();
    return doc.exists ? Estabelecimento.fromMap(doc.data()!) : null;
  }

  @override
  Future<List<Estabelecimento>> getEstabelecimentos() async {
    final snapshot = await _db.collection('estabelecimentos').get();
    return snapshot.docs.map((doc) => Estabelecimento.fromMap(doc.data()!)).toList();
  }

  @override
  Future<Estabelecimento?> getFirstEstabelecimento() async {
    // Provisório: Pega o primeiro que achar para simular o login da empresa
    final snapshot = await _db.collection('estabelecimentos').limit(1).get();
    return snapshot.docs.isNotEmpty ? Estabelecimento.fromMap(snapshot.docs.first.data()!) : null;
  }

  @override
  Future<void> updateEstabelecimento(Estabelecimento est) async {
    if (est.id == null) return;
    await _db.collection('estabelecimentos').doc(est.id).update(est.toMap());
  }

  @override
  Future<void> deleteEstabelecimento(String id) async {
    await _db.collection('estabelecimentos').doc(id).delete();
  }

  @override
  Future<void> criarQrCode(String estabelecimentoId, String token) async {
    // Usamos o próprio token como ID do documento para busca rápida O(1)
    await _db.collection('qr_codes').doc(token).set({
      'estabelecimento_id': estabelecimentoId,
      'token': token,
      'usado': 0,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>?> getQrCode(String token) async {
    final doc = await _db.collection('qr_codes').doc(token).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> marcarQrComoUsado(String token) async {
    await _db.collection('qr_codes').doc(token).update({
      'usado': 1,
      'usado_em': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> insertRecompensa(Recompensa rec) async {
    final docRef = _db.collection('recompensas').doc();
    final data = rec.toMap();
    data['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  @override
  Future<List<Recompensa>> getRecompensasByEstabelecimento(String estId) async {
    final snapshot = await _db.collection('recompensas')
        .where('estabelecimento_id', isEqualTo: estId)
        .get();
    return snapshot.docs.map((doc) => Recompensa.fromMap(doc.data()!)).toList();
  }

  @override
  Future<void> updateRecompensa(Recompensa rec) async {
    if (rec.id == null) return;
    await _db.collection('recompensas').doc(rec.id).update(rec.toMap());
  }

  @override
  Future<void> deleteRecompensa(String id) async {
    await _db.collection('recompensas').doc(id).delete();
  }
}
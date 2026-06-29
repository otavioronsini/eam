import 'package:cloud_firestore/cloud_firestore.dart';
import 'cliente_repository.dart';
import '../funcionalidades/cliente.dart';

class FirestoreClienteRepository implements ClienteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<String> insertCliente(Cliente cliente) async {
    // Se o cliente já possuir um ID (vindo do Firebase Auth), usa ele.
    // Caso contrário, gera um novo documento em branco com ID automático.
    final docRef = cliente.id != null && cliente.id!.isNotEmpty
        ? _db.collection('clientes').doc(cliente.id)
        : _db.collection('clientes').doc();

    final data = cliente.toMap();
    data['id'] = docRef.id; // Garante que o ID no banco é exatamente o ID do Auth

    await docRef.set(data);
    return docRef.id;
  }

  @override
  Future<Cliente?> getCliente(String id) async {
    final doc = await _db.collection('clientes').doc(id).get();
    return doc.exists ? Cliente.fromMap(doc.data()!) : null;
  }

  @override
  Future<List<Cliente>> getClientes() async {
    final snapshot = await _db.collection('clientes').get();
    return snapshot.docs.map((doc) => Cliente.fromMap(doc.data()!)).toList();
  }

  @override
  Future<Cliente?> getFirstCliente() async {
    final snapshot = await _db.collection('clientes').limit(1).get();
    return snapshot.docs.isNotEmpty ? Cliente.fromMap(snapshot.docs.first.data()!) : null;
  }

  @override
  Future<Map<String, dynamic>> getOrCreatePontos(String clienteId, String estabelecimentoId) async {
    final docId = '${clienteId}_$estabelecimentoId';
    final docRef = _db.collection('pontos').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) return doc.data()!;

    final newDoc = {
      'id': docId,
      'cliente_id': clienteId,
      'estabelecimento_id': estabelecimentoId,
      'saldo': 0,
      'total_ganhos': 0,
      'total_utilizados': 0,
    };
    await docRef.set(newDoc);
    return newDoc;
  }

  @override
  Future<int> adicionarPontos(String clienteId, String estabelecimentoId, int quantidade) async {
    final docId = '${clienteId}_$estabelecimentoId';
    final docRef = _db.collection('pontos').doc(docId);

    await getOrCreatePontos(clienteId, estabelecimentoId);

    int novoSaldo = 0;
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final saldo = snapshot.data()?['saldo'] as int? ?? 0;
      final ganhos = snapshot.data()?['total_ganhos'] as int? ?? 0;

      novoSaldo = saldo + quantidade;
      transaction.update(docRef, {
        'saldo': novoSaldo,
        'total_ganhos': ganhos + quantidade,
      });
    });
    return novoSaldo;
  }

  @override
  Future<bool> resgatarPontos(String clienteId, String estabelecimentoId, int quantidade) async {
    final docId = '${clienteId}_$estabelecimentoId';
    final docRef = _db.collection('pontos').doc(docId);

    bool sucesso = false;
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final saldo = snapshot.data()?['saldo'] as int? ?? 0;
      final utilizados = snapshot.data()?['total_utilizados'] as int? ?? 0;

      if (saldo >= quantidade) {
        transaction.update(docRef, {
          'saldo': saldo - quantidade,
          'total_utilizados': utilizados + quantidade,
        });
        sucesso = true;
      }
    });
    return sucesso;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPontosByCliente(String clienteId) async {
    final snapshot = await _db.collection('pontos').where('cliente_id', isEqualTo: clienteId).get();
    List<Map<String, dynamic>> resultados = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final estDoc = await _db.collection('estabelecimentos').doc(data['estabelecimento_id']).get();
      if (estDoc.exists) {
        data['nome'] = estDoc.data()?['nome'];
        resultados.add(data);
      }
    }
    return resultados;
  }

  @override
  Future<Map<String, int>> getTotaisGlobais(String clienteId) async {
    final snapshot = await _db.collection('pontos').where('cliente_id', isEqualTo: clienteId).get();
    int saldo = 0, ganhos = 0, utilizados = 0;

    for (var doc in snapshot.docs) {
      saldo += (doc.data()['saldo'] as int?) ?? 0;
      ganhos += (doc.data()['total_ganhos'] as int?) ?? 0;
      utilizados += (doc.data()['total_utilizados'] as int?) ?? 0;
    }
    return {'total_saldo': saldo, 'total_ganhos': ganhos, 'total_utilizados': utilizados};
  }
}
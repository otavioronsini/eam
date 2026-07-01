import 'package:cloud_firestore/cloud_firestore.dart';
import 'empresa_repository.dart';
import '../funcionalidades/empresa.dart';
import '../funcionalidades/plano.dart';

class FirestoreEmpresaRepository implements EmpresaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _empresas =>
      _db.collection('empresas');

  @override
  Future<void> garantirEmpresa(String id, String nome, String email) async {
    final docRef = _empresas.doc(id);
    final doc = await docRef.get();
    if (doc.exists) return;

    final empresa = Empresa.novo(id: id, nome: nome, email: email.trim().toLowerCase());
    await docRef.set(empresa.toMap());
  }

  @override
  Future<Empresa?> getEmpresa(String id) async {
    final doc = await _empresas.doc(id).get();
    final data = doc.data();
    return (doc.exists && data != null) ? Empresa.fromMap(data) : null;
  }

  @override
  Future<void> solicitarPlano(String id, String plano) async {
    await _empresas.doc(id).update({
      'planoSolicitado': plano,
      'statusPagamento': 'pendente',
    });
  }

  @override
  Future<void> cancelarSolicitacao(String id) async {
    await _empresas.doc(id).update({
      'planoSolicitado': null,
      'statusPagamento': 'nenhum',
    });
  }

  @override
  Future<void> liberarPlano(String id, String plano) async {
    final agora = DateTime.now();
    // Soma 1 mês. O DateTime do Dart normaliza overflow de mês sozinho
    // (mês 13 vira janeiro do ano seguinte).
    final expiraEm = DateTime(agora.year, agora.month + 1, agora.day);

    await _empresas.doc(id).update({
      'plano': plano,
      'statusPagamento': 'aprovado',
      'planoSolicitado': null,
      'assinaturaInicio': Timestamp.fromDate(agora),
      'assinaturaExpiraEm': Timestamp.fromDate(expiraEm),
    });
  }

  @override
  Future<void> revogarAssinatura(String id) async {
    await _empresas.doc(id).update({
      'plano': Plano.gratis,
      'statusPagamento': 'nenhum',
      'planoSolicitado': null,
      'assinaturaExpiraEm': null,
    });
  }

  @override
  Future<List<Empresa>> getSolicitacoesPendentes() async {
    final snap = await _empresas
        .where('statusPagamento', isEqualTo: 'pendente')
        .get();
    return snap.docs.map((d) => Empresa.fromMap(d.data())).toList();
  }

  @override
  Future<List<Empresa>> getTodasEmpresas() async {
    final snap = await _empresas.get();
    return snap.docs.map((d) => Empresa.fromMap(d.data())).toList();
  }

  @override
  Future<Empresa?> buscarPorEmail(String email) async {
    final alvo = email.trim().toLowerCase();
    if (alvo.isEmpty) return null;

    final snap =
        await _empresas.where('email', isEqualTo: alvo).limit(1).get();
    if (snap.docs.isNotEmpty) {
      return Empresa.fromMap(snap.docs.first.data());
    }

    // Fallback para contas antigas cujo e-mail foi salvo sem normalizar
    // (com maiúsculas, por exemplo): procura entre todas as empresas.
    final todas = await getTodasEmpresas();
    for (final empresa in todas) {
      if (empresa.email.trim().toLowerCase() == alvo) return empresa;
    }
    return null;
  }

  @override
  Future<void> definirLimiteExtra(String id, int? limite) async {
    await _empresas.doc(id).update({'limiteExtra': limite});
  }
}

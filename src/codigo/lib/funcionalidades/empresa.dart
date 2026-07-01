import 'package:cloud_firestore/cloud_firestore.dart';
import 'plano.dart';

/// Representa a conta de uma Empresa e o estado da sua assinatura.
///
/// O documento vive em `empresas/{id}`, onde `id` é o mesmo uid do
/// Firebase Auth usado como `empresaId` nos estabelecimentos.
class Empresa {
  final String id;
  final String nome;
  final String email;

  /// Último plano efetivamente liberado (pode estar vencido, veja [planoEfetivo]).
  final String plano;

  /// 'nenhum' | 'pendente' | 'aprovado'
  final String statusPagamento;

  /// Plano que a empresa pediu para assinar e está aguardando liberação.
  final String? planoSolicitado;

  final DateTime? assinaturaInicio;
  final DateTime? assinaturaExpiraEm;

  /// Conta de administrador (definida manualmente no console do Firebase).
  /// Dá acesso ao painel de aprovação e a botões de teste de plano.
  final bool admin;

  /// Permissão manual concedida por um superusuário: quantidade de
  /// restaurantes que essa empresa pode cadastrar, independente do plano
  /// contratado. Quando definida e maior que o limite do plano em vigor,
  /// prevalece sobre ele (veja [limiteEstabelecimentos]). `null` significa
  /// que nenhuma permissão extra foi concedida.
  final int? limiteExtra;

  Empresa({
    required this.id,
    required this.nome,
    required this.email,
    this.plano = Plano.gratis,
    this.statusPagamento = 'nenhum',
    this.planoSolicitado,
    this.assinaturaInicio,
    this.assinaturaExpiraEm,
    this.admin = false,
    this.limiteExtra,
  });

  factory Empresa.novo({
    required String id,
    required String nome,
    required String email,
  }) {
    return Empresa(id: id, nome: nome, email: email);
  }

  /// Plano realmente em vigor agora. Se a assinatura paga já venceu, volta
  /// sozinho para o grátis — sem precisar de nenhum job/cron rodando.
  String get planoEfetivo {
    if (plano == Plano.gratis) return Plano.gratis;
    if (assinaturaExpiraEm == null) return Plano.gratis;
    if (assinaturaExpiraEm!.isBefore(DateTime.now())) return Plano.gratis;
    return plano;
  }

  bool get assinaturaAtiva => planoEfetivo != Plano.gratis;

  int get limiteEstabelecimentos {
    final limitePlano = Plano.limiteDe(planoEfetivo);
    if (limiteExtra != null && limiteExtra! > limitePlano) return limiteExtra!;
    return limitePlano;
  }

  int? get diasRestantes {
    if (!assinaturaAtiva || assinaturaExpiraEm == null) return null;
    return assinaturaExpiraEm!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'plano': plano,
      'statusPagamento': statusPagamento,
      'planoSolicitado': planoSolicitado,
      'assinaturaInicio': assinaturaInicio != null
          ? Timestamp.fromDate(assinaturaInicio!)
          : null,
      'assinaturaExpiraEm': assinaturaExpiraEm != null
          ? Timestamp.fromDate(assinaturaExpiraEm!)
          : null,
      'admin': admin,
      'limiteExtra': limiteExtra,
    };
  }

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      id: map['id'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      plano: map['plano'] as String? ?? Plano.gratis,
      statusPagamento: map['statusPagamento'] as String? ?? 'nenhum',
      planoSolicitado: map['planoSolicitado'] as String?,
      assinaturaInicio: (map['assinaturaInicio'] as Timestamp?)?.toDate(),
      assinaturaExpiraEm: (map['assinaturaExpiraEm'] as Timestamp?)?.toDate(),
      admin: map['admin'] as bool? ?? false,
      limiteExtra: map['limiteExtra'] as int?,
    );
  }

  Empresa copyWith({
    String? nome,
    String? email,
    String? plano,
    String? statusPagamento,
    DateTime? assinaturaInicio,
    DateTime? assinaturaExpiraEm,
    bool? admin,
    int? limiteExtra,
  }) {
    return Empresa(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      plano: plano ?? this.plano,
      statusPagamento: statusPagamento ?? this.statusPagamento,
      planoSolicitado: planoSolicitado,
      assinaturaInicio: assinaturaInicio ?? this.assinaturaInicio,
      assinaturaExpiraEm: assinaturaExpiraEm ?? this.assinaturaExpiraEm,
      admin: admin ?? this.admin,
      limiteExtra: limiteExtra ?? this.limiteExtra,
    );
  }
}

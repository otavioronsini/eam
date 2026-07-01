import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa um registro no histórico de pedidos: toda vez que um cliente
/// resgata (consome) pontos em troca de uma recompensa, um Pedido é criado
/// associando o e-mail do cliente ao que foi comprado.
class Pedido {
  final String? id;
  final String estabelecimentoId;
  final String clienteId;
  final String clienteEmail;
  final String clienteNome;
  final String recompensaNome;
  final int pontosUtilizados;
  final DateTime? criadoEm;

  Pedido({
    this.id,
    required this.estabelecimentoId,
    required this.clienteId,
    required this.clienteEmail,
    required this.clienteNome,
    required this.recompensaNome,
    required this.pontosUtilizados,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estabelecimento_id': estabelecimentoId,
      'cliente_id': clienteId,
      'cliente_email': clienteEmail,
      'cliente_nome': clienteNome,
      'recompensa_nome': recompensaNome,
      'pontos_utilizados': pontosUtilizados,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    final criadoEmRaw = map['criado_em'];
    return Pedido(
      id: map['id'] as String?,
      estabelecimentoId: map['estabelecimento_id'] as String? ?? '',
      clienteId: map['cliente_id'] as String? ?? '',
      clienteEmail: map['cliente_email'] as String? ?? '',
      clienteNome: map['cliente_nome'] as String? ?? '',
      recompensaNome: map['recompensa_nome'] as String? ?? '',
      pontosUtilizados: (map['pontos_utilizados'] as num?)?.toInt() ?? 0,
      criadoEm: criadoEmRaw is Timestamp ? criadoEmRaw.toDate() : null,
    );
  }
}

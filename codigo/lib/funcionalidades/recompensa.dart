class Recompensa {
  final String? id; // Alterado para String?
  final String estabelecimentoId; // Alterado para String
  final String nome;
  final String descricao;
  final int pontosNecessarios;

  Recompensa({
    this.id,
    required this.estabelecimentoId,
    required this.nome,
    required this.descricao,
    required this.pontosNecessarios,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estabelecimento_id': estabelecimentoId,
      'nome': nome,
      'descricao': descricao,
      'pontos_necessarios': pontosNecessarios,
    };
  }

  factory Recompensa.fromMap(Map<String, dynamic> map) {
    return Recompensa(
      id: map['id'] as String?,
      estabelecimentoId: map['estabelecimento_id'] as String,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      pontosNecessarios: map['pontos_necessarios'] as int,
    );
  }

  Recompensa copyWith({
    String? id,
    String? estabelecimentoId,
    String? nome,
    String? descricao,
    int? pontosNecessarios,
  }) {
    return Recompensa(
      id: id ?? this.id,
      estabelecimentoId: estabelecimentoId ?? this.estabelecimentoId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      pontosNecessarios: pontosNecessarios ?? this.pontosNecessarios,
    );
  }
}
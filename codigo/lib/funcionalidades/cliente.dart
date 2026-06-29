class Cliente {
  final String? id; // Alterado para String?
  final String nome;
  final String email;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as String?,
      nome: map['nome'] as String,
      email: map['email'] as String,
    );
  }

  Cliente copyWith({
    String? id,
    String? nome,
    String? email,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
    );
  }
}
class Cliente {
  final String? id; // Alterado para String?
  final String nome;
  final String email;
  final String? fotoPath;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'fotoPath': fotoPath,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as String?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      fotoPath: map['fotoPath'] as String?,
    );
  }

  Cliente copyWith({
    String? id,
    String? nome,
    String? email,
    String? fotoPath,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
}
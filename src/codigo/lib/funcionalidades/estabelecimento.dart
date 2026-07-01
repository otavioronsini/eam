class Estabelecimento {
  final String? id;
  final String? empresaId;
  final String nome;
  final double latitude;
  final double longitude;
  final String descricao;
  final String? fotoPath;
  final int pontosPorVisita;
  final String? qrCodeData;

  // Novos campos
  final String? cep;
  final String? rua;
  final String? numero;
  final String? bairro;
  final String? cidade;

  Estabelecimento({
    this.id,
    this.empresaId,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.descricao,
    this.fotoPath,
    this.pontosPorVisita = 1,
    this.qrCodeData,
    this.cep,
    this.rua,
    this.numero,
    this.bairro,
    this.cidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresaId': empresaId,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
      'fotoPath': fotoPath,
      'pontosPorVisita': pontosPorVisita,
      'qrCodeData': qrCodeData,
      'cep': cep,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
    };
  }

  factory Estabelecimento.fromMap(Map<String, dynamic> map) {
    return Estabelecimento(
      id: map['id'] as String?,
      empresaId: map['empresaId'] as String?,
      nome: map['nome'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      descricao: map['descricao'] as String? ?? '',
      fotoPath: map['fotoPath'] as String?,
      pontosPorVisita: (map['pontosPorVisita'] as num?)?.toInt() ?? 1,
      qrCodeData: map['qrCodeData'] as String?,
      cep: map['cep'] as String?,
      rua: map['rua'] as String?,
      numero: map['numero'] as String?,
      bairro: map['bairro'] as String?,
      cidade: map['cidade'] as String?,
    );
  }

  Estabelecimento copyWith({
    String? id,
    String? empresaId,
    String? nome,
    double? latitude,
    double? longitude,
    String? descricao,
    String? fotoPath,
    int? pontosPorVisita,
    String? qrCodeData,
    String? cep,
    String? rua,
    String? numero,
    String? bairro,
    String? cidade,
  }) {
    return Estabelecimento(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descricao: descricao ?? this.descricao,
      fotoPath: fotoPath ?? this.fotoPath,
      pontosPorVisita: pontosPorVisita ?? this.pontosPorVisita,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      cep: cep ?? this.cep,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
    );
  }
}

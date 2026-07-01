import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'estabelecimento.dart';
import 'cliente.dart';
import 'recompensa.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE estabelecimentos (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        nome            TEXT    NOT NULL,
        latitude        REAL    NOT NULL,
        longitude       REAL    NOT NULL,
        descricao       TEXT    NOT NULL,
        fotoPath        TEXT,
        pontosPorVisita INTEGER NOT NULL DEFAULT 10,
        qrCodeData      TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT    NOT NULL,
        email TEXT   NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recompensas (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        estabelecimento_id INTEGER NOT NULL,
        nome               TEXT    NOT NULL,
        descricao          TEXT    NOT NULL,
        pontos_necessarios INTEGER NOT NULL,
        FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pontos (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id         INTEGER NOT NULL,
        estabelecimento_id INTEGER NOT NULL,
        saldo              INTEGER NOT NULL DEFAULT 0,
        total_ganhos       INTEGER NOT NULL DEFAULT 0,
        total_utilizados   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
        FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE qr_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estabelecimento_id INTEGER NOT NULL,
        token TEXT NOT NULL UNIQUE,
        usado INTEGER NOT NULL DEFAULT 0,
        criado_em TEXT NOT NULL,
        usado_em TEXT,
        FOREIGN KEY (estabelecimento_id)
          REFERENCES estabelecimentos(id)
          ON DELETE CASCADE
  )
''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE estabelecimentos ADD COLUMN fotoPath TEXT');
      await db.execute(
        'ALTER TABLE estabelecimentos ADD COLUMN pontosPorVisita INTEGER NOT NULL DEFAULT 10',
      );
      await db.execute(
        'ALTER TABLE estabelecimentos ADD COLUMN qrCodeData TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE clientes (
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT    NOT NULL,
          email TEXT   NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE recompensas (
          id                 INTEGER PRIMARY KEY AUTOINCREMENT,
          estabelecimento_id INTEGER NOT NULL,
          nome               TEXT    NOT NULL,
          descricao          TEXT    NOT NULL,
          pontos_necessarios INTEGER NOT NULL,
          FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE pontos (
          id                 INTEGER PRIMARY KEY AUTOINCREMENT,
          cliente_id         INTEGER NOT NULL,
          estabelecimento_id INTEGER NOT NULL,
          saldo              INTEGER NOT NULL DEFAULT 0,
          total_ganhos       INTEGER NOT NULL DEFAULT 0,
          total_utilizados   INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
          FOREIGN KEY (estabelecimento_id) REFERENCES estabelecimentos(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE qr_codes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          estabelecimento_id INTEGER NOT NULL,
          token TEXT NOT NULL UNIQUE,
          usado INTEGER NOT NULL DEFAULT 0,
          criado_em TEXT NOT NULL,
          usado_em TEXT,
          FOREIGN KEY (estabelecimento_id)
            REFERENCES estabelecimentos(id)
            ON DELETE CASCADE
    )
  ''');
    }
  }

  // ===================================================================
  // ESTABELECIMENTO CRUD
  // ===================================================================

  Future<int> insertEstabelecimento(Estabelecimento est) async {
    final db = await database;
    return db.insert('estabelecimentos', est.toMap());
  }

  Future<Estabelecimento?> getEstabelecimento(int id) async {
    final db = await database;
    final maps = await db.query(
      'estabelecimentos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Estabelecimento.fromMap(maps.first);
  }

  Future<Map<String, dynamic>?> getQrCode(String token) async {
    final db = await database;

    final maps = await db.query(
      'qr_codes',
      where: 'token = ?',
      whereArgs: [token],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return maps.first;
  }

  Future<List<Estabelecimento>> getEstabelecimentos() async {
    final db = await database;
    final maps = await db.query('estabelecimentos');
    return maps.map((m) => Estabelecimento.fromMap(m)).toList();
  }

  Future<Estabelecimento?> getFirstEstabelecimento() async {
    final db = await database;
    final maps = await db.query('estabelecimentos', limit: 1);
    if (maps.isEmpty) return null;
    return Estabelecimento.fromMap(maps.first);
  }

  Future<int> updateEstabelecimento(Estabelecimento est) async {
    final db = await database;
    return db.update(
      'estabelecimentos',
      est.toMap(),
      where: 'id = ?',
      whereArgs: [est.id],
    );
  }

  Future<int> deleteEstabelecimento(int id) async {
    final db = await database;
    return db.delete('estabelecimentos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> criarQrCode(int estabelecimentoId, String token) async {
    final db = await database;

    await db.insert('qr_codes', {
      'estabelecimento_id': estabelecimentoId,
      'token': token,
      'usado': 0,
      'criado_em': DateTime.now().toIso8601String(),
    });
  }

  // ===================================================================
  // CLIENTE CRUD
  // ===================================================================

  Future<int> insertCliente(Cliente cliente) async {
    final db = await database;
    return db.insert('clientes', cliente.toMap());
  }

  Future<Cliente?> getCliente(int id) async {
    final db = await database;
    final maps = await db.query('clientes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Cliente.fromMap(maps.first);
  }

  Future<List<Cliente>> getClientes() async {
    final db = await database;
    final maps = await db.query('clientes');
    return maps.map((m) => Cliente.fromMap(m)).toList();
  }

  Future<Cliente?> getFirstCliente() async {
    final db = await database;
    final maps = await db.query('clientes', limit: 1);
    if (maps.isEmpty) return null;
    return Cliente.fromMap(maps.first);
  }

  Future<int> updateCliente(Cliente cliente) async {
    final db = await database;
    return db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await database;
    return db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  // ===================================================================
  // RECOMPENSA CRUD
  // ===================================================================

  Future<int> insertRecompensa(Recompensa rec) async {
    final db = await database;
    return db.insert('recompensas', rec.toMap());
  }

  Future<List<Recompensa>> getRecompensasByEstabelecimento(int estId) async {
    final db = await database;
    final maps = await db.query(
      'recompensas',
      where: 'estabelecimento_id = ?',
      whereArgs: [estId],
    );
    return maps.map((m) => Recompensa.fromMap(m)).toList();
  }

  Future<Recompensa?> getRecompensa(int id) async {
    final db = await database;
    final maps = await db.query(
      'recompensas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Recompensa.fromMap(maps.first);
  }

  Future<int> updateRecompensa(Recompensa rec) async {
    final db = await database;
    return db.update(
      'recompensas',
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  Future<int> deleteRecompensa(int id) async {
    final db = await database;
    return db.delete('recompensas', where: 'id = ?', whereArgs: [id]);
  }

  // ===================================================================
  // PONTOS
  // ===================================================================

  /// Retorna o registro de pontos de um cliente em um estabelecimento.
  /// Se não existir, cria um novo com saldo zero.
  Future<Map<String, dynamic>> getOrCreatePontos(
    int clienteId,
    int estabelecimentoId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'pontos',
      where: 'cliente_id = ? AND estabelecimento_id = ?',
      whereArgs: [clienteId, estabelecimentoId],
    );
    if (maps.isNotEmpty) return maps.first;

    final id = await db.insert('pontos', {
      'cliente_id': clienteId,
      'estabelecimento_id': estabelecimentoId,
      'saldo': 0,
      'total_ganhos': 0,
      'total_utilizados': 0,
    });
    return (await db.query('pontos', where: 'id = ?', whereArgs: [id])).first;
  }

  /// Adiciona pontos à conta de um cliente em um estabelecimento.
  /// Retorna o novo saldo.
  Future<int> adicionarPontos(
    int clienteId,
    int estabelecimentoId,
    int quantidade,
  ) async {
    final db = await database;
    final row = await getOrCreatePontos(clienteId, estabelecimentoId);
    final pontosId = row['id'] as int;
    final saldoAtual = row['saldo'] as int;
    final totalGanhos = row['total_ganhos'] as int;

    final novoSaldo = saldoAtual + quantidade;
    final novoTotalGanhos = totalGanhos + quantidade;

    await db.update(
      'pontos',
      {'saldo': novoSaldo, 'total_ganhos': novoTotalGanhos},
      where: 'id = ?',
      whereArgs: [pontosId],
    );

    return novoSaldo;
  }

  Future<void> marcarQrComoUsado(String token) async {
    final db = await database;

    await db.update(
      'qr_codes',
      {'usado': 1, 'usado_em': DateTime.now().toIso8601String()},
      where: 'token = ?',
      whereArgs: [token],
    );
  }

  /// Resgata pontos (utiliza) de um cliente em um estabelecimento.
  /// Retorna true se bem-sucedido, false se saldo insuficiente.
  Future<bool> resgatarPontos(
    int clienteId,
    int estabelecimentoId,
    int quantidade,
  ) async {
    final db = await database;
    final row = await getOrCreatePontos(clienteId, estabelecimentoId);
    final pontosId = row['id'] as int;
    final saldoAtual = row['saldo'] as int;
    final totalUtilizados = row['total_utilizados'] as int;

    if (saldoAtual < quantidade) return false;

    await db.update(
      'pontos',
      {
        'saldo': saldoAtual - quantidade,
        'total_utilizados': totalUtilizados + quantidade,
      },
      where: 'id = ?',
      whereArgs: [pontosId],
    );

    return true;
  }

  /// Retorna os pontos de um cliente em um estabelecimento específico.
  Future<Map<String, dynamic>?> getPontos(
    int clienteId,
    int estabelecimentoId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'pontos',
      where: 'cliente_id = ? AND estabelecimento_id = ?',
      whereArgs: [clienteId, estabelecimentoId],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna todos os registros de pontos de um cliente (com dados do estabelecimento).
  Future<List<Map<String, dynamic>>> getAllPontosByCliente(
    int clienteId,
  ) async {
    final db = await database;
    return db.rawQuery(
      '''
      SELECT p.*, e.nome, e.latitude, e.longitude, e.descricao, e.fotoPath
      FROM pontos p
      INNER JOIN estabelecimentos e ON e.id = p.estabelecimento_id
      WHERE p.cliente_id = ?
      ORDER BY p.saldo DESC
      ''',
      [clienteId],
    );
  }

  /// Retorna totais globais de um cliente (todos estabelecimentos).
  Future<Map<String, int>> getTotaisGlobais(int clienteId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(saldo), 0) AS total_saldo,
             COALESCE(SUM(total_ganhos), 0) AS total_ganhos,
             COALESCE(SUM(total_utilizados), 0) AS total_utilizados
      FROM pontos
      WHERE cliente_id = ?
      ''',
      [clienteId],
    );
    final row = result.first;
    return {
      'total_saldo': (row['total_saldo'] as int?) ?? 0,
      'total_ganhos': (row['total_ganhos'] as int?) ?? 0,
      'total_utilizados': (row['total_utilizados'] as int?) ?? 0,
    };
  }
}

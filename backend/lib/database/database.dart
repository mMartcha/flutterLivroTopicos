import 'package:sqlite3/sqlite3.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  late final Database db;

  AppDatabase._internal() {
    db = sqlite3.open('biblioteca.db');
    db.execute('PRAGMA foreign_keys = ON');
    _createTables();
  }

  void _createTables() {
    // Para bancos NOVOS (primeira execucao), ja criamos a tabela de autores
    // com a coluna 'nacionalidade'.
    db.execute('''
      CREATE TABLE IF NOT EXISTS autores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        nacionalidade TEXT NOT NULL DEFAULT ''
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS livros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        ano INTEGER NOT NULL,
        autor_id INTEGER NOT NULL,
        FOREIGN KEY (autor_id) REFERENCES autores (id)
      )
    ''');

    // Migracao simples: bancos que ja existiam (criados antes da coluna nova)
    // nao tem 'nacionalidade'. Aqui garantimos que ela exista.
    _adicionarColunaNacionalidadeSeNecessario();
  }

  // Tenta adicionar a coluna 'nacionalidade' na tabela de autores.
  // Se a coluna JA existir, o SQLite lanca um erro -- que ignoramos de
  // proposito (o try/catch vazio significa "tudo bem, ja esta criada").
  void _adicionarColunaNacionalidadeSeNecessario() {
    try {
      db.execute(
        "ALTER TABLE autores ADD COLUMN nacionalidade TEXT NOT NULL DEFAULT ''",
      );
    } catch (_) {
      // A coluna ja existe: nada a fazer.
    }
  }
}

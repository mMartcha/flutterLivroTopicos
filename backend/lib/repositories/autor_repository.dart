import '../database/database.dart';
import '../models/autor.dart';

class AutorRepository {
  final database = AppDatabase().db;

  Autor criar(Autor autor) {
    final stmt = database.prepare(
      'INSERT INTO autores (nome, nacionalidade) VALUES (?, ?)',
    );

    stmt.execute([autor.nome, autor.nacionalidade]);
    stmt.close();

    final result = database.select('SELECT last_insert_rowid() AS id');
    final id = result.first['id'] as int;

    return Autor(
      id: id,
      nome: autor.nome,
      nacionalidade: autor.nacionalidade,
    );
  }

  List<Autor> listar() {
    final result = database.select('SELECT * FROM autores ORDER BY id');

    return result
        .map(
          (row) => Autor.fromRow({
            'id': row['id'],
            'nome': row['nome'],
            'nacionalidade': row['nacionalidade'],
          }),
        )
        .toList();
  }

  Autor? buscarPorId(int id) {
    final result = database.select(
      'SELECT * FROM autores WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Autor.fromRow({
      'id': row['id'],
      'nome': row['nome'],
      'nacionalidade': row['nacionalidade'],
    });
  }

  Autor? atualizar(int id, Autor autor) {
    final existente = buscarPorId(id);
    if (existente == null) return null;

    final stmt = database.prepare(
      'UPDATE autores SET nome = ?, nacionalidade = ? WHERE id = ?',
    );

    stmt.execute([autor.nome, autor.nacionalidade, id]);
    stmt.close();

    return Autor(
      id: id,
      nome: autor.nome,
      nacionalidade: autor.nacionalidade,
    );
  }

  bool remover(int id) {
    final existente = buscarPorId(id);
    if (existente == null) return false;

    final stmt = database.prepare('DELETE FROM autores WHERE id = ?');
    stmt.execute([id]);
    stmt.close();

    return true;
  }

  bool possuiLivros(int id) {
    final result = database.select(
      'SELECT COUNT(*) AS total FROM livros WHERE autor_id = ?',
      [id],
    );

    return (result.first['total'] as int) > 0;
  }
}

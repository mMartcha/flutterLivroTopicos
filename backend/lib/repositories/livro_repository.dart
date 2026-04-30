import '../database/database.dart';
import '../models/livro.dart';

class LivroRepository {
  final database = AppDatabase().db;

  Livro criar(Livro livro) {
    final stmt = database.prepare(
      'INSERT INTO livros (titulo, ano, autor_id) VALUES (?, ?, ?)',
    );

    stmt.execute([livro.titulo, livro.ano, livro.autorId]);
    stmt.close();

    final result = database.select('SELECT last_insert_rowid() AS id');
    final id = result.first['id'] as int;

    return Livro(
      id: id,
      titulo: livro.titulo,
      ano: livro.ano,
      autorId: livro.autorId,
    );
  }

  List<Livro> listar() {
    final result = database.select('SELECT * FROM livros ORDER BY id');

    return result
        .map(
          (row) => Livro.fromRow({
            'id': row['id'],
            'titulo': row['titulo'],
            'ano': row['ano'],
            'autor_id': row['autor_id'],
          }),
        )
        .toList();
  }

  List<Livro> listarPorAutor(int autorId) {
    final result = database.select(
      'SELECT * FROM livros WHERE autor_id = ? ORDER BY id',
      [autorId],
    );

    return result
        .map(
          (row) => Livro.fromRow({
            'id': row['id'],
            'titulo': row['titulo'],
            'ano': row['ano'],
            'autor_id': row['autor_id'],
          }),
        )
        .toList();
  }

  Livro? buscarPorId(int id) {
    final result = database.select(
      'SELECT * FROM livros WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return Livro.fromRow({
      'id': row['id'],
      'titulo': row['titulo'],
      'ano': row['ano'],
      'autor_id': row['autor_id'],
    });
  }

  Livro? atualizar(int id, Livro livro) {
    final existente = buscarPorId(id);
    if (existente == null) return null;

    final stmt = database.prepare(
      'UPDATE livros SET titulo = ?, ano = ?, autor_id = ? WHERE id = ?',
    );

    stmt.execute([livro.titulo, livro.ano, livro.autorId, id]);
    stmt.close();

    return Livro(
      id: id,
      titulo: livro.titulo,
      ano: livro.ano,
      autorId: livro.autorId,
    );
  }

  bool remover(int id) {
    final existente = buscarPorId(id);
    if (existente == null) return false;

    final stmt = database.prepare('DELETE FROM livros WHERE id = ?');
    stmt.execute([id]);
    stmt.close();

    return true;
  }
}

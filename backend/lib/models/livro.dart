class Livro {
  final int? id;
  final String titulo;
  final int ano;
  final int autorId;

  Livro({
    this.id,
    required this.titulo,
    required this.ano,
    required this.autorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'ano': ano,
      'autorId': autorId,
    };
  }

  factory Livro.fromRow(Map<String, dynamic> row) {
    return Livro(
      id: row['id'] as int?,
      titulo: row['titulo'] as String,
      ano: row['ano'] as int,
      autorId: row['autor_id'] as int,
    );
  }
}

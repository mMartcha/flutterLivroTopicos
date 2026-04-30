class Autor {
  final int? id;
  final String nome;

  Autor({
    this.id,
    required this.nome,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Autor.fromRow(Map<String, dynamic> row) {
    return Autor(
      id: row['id'] as int?,
      nome: row['nome'] as String,
    );
  }
}

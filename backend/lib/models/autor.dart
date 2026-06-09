// Arquivo: lib/models/autor.dart
// O que faz: representa um Autor (entidade PAI) dentro do backend.
// Quando e usado: nas rotas e no repositorio, para transformar dados do banco
// em objeto Dart (fromRow) e em JSON para enviar na resposta (toJson).

class Autor {
  // id pode ser nulo porque, ao CRIAR um autor, ainda nao temos o id
  // (o banco gera o id automaticamente).
  final int? id;
  final String nome; // obrigatorio
  final String nacionalidade; // obrigatorio

  Autor({
    this.id,
    required this.nome,
    required this.nacionalidade,
  });

  // toJson: transforma o autor em um Map (que vira JSON na resposta da API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }

  // fromRow: cria um Autor a partir de uma linha lida do banco de dados.
  factory Autor.fromRow(Map<String, dynamic> row) {
    return Autor(
      id: row['id'] as int?,
      nome: row['nome'] as String,
      nacionalidade: row['nacionalidade'] as String,
    );
  }
}

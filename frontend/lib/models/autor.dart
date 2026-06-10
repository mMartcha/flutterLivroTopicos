class Autor {
  final int id;
  final String nome;
  final String nacionalidade;

  const Autor({
    required this.id,
    required this.nome,
    required this.nacionalidade,
  });

  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      id: json['id'] as int,
      nome: json['nome'] as String,
      nacionalidade: json['nacionalidade'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }
}

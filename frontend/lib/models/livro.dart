class Livro {
  final int id;
  final String titulo;
  final int ano;
  final int autorId;

  const Livro({
    required this.id,
    required this.titulo,
    required this.ano,
    required this.autorId,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      ano: json['ano'] as int,
      autorId: json['autorId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'ano': ano,
      'autorId': autorId,
    };
  }
}

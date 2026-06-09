// Arquivo: lib/models/livro.dart
// O que faz: representa um Livro dentro do app (o "molde" dos dados).
// Quando e usado: sempre que precisamos transformar o JSON que veio da API
// em um objeto Dart (fromJson) ou transformar o objeto de volta em JSON
// para enviar para a API (toJson).

class Livro {
  // Campos do livro. Sao "final" porque, depois de criado, o objeto nao muda.
  final int id; // gerado pela API
  final String titulo; // obrigatorio
  final int ano; // obrigatorio
  final int autorId; // obrigatorio (numero do autor)

  // Construtor: usamos "const" porque os campos sao todos final.
  const Livro({
    required this.id,
    required this.titulo,
    required this.ano,
    required this.autorId,
  });

  // fromJson: cria um Livro a partir do Map que veio do JSON da API.
  // Ex.: {"id": 1, "titulo": "Dom Casmurro", "ano": 1899, "autorId": 2}
  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      ano: json['ano'] as int,
      autorId: json['autorId'] as int,
    );
  }

  // toJson: transforma o Livro em um Map para enviar no corpo das requisicoes.
  // Nao enviamos o 'id' porque a API gera o id no POST e usa o id da URL no PUT.
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'ano': ano,
      'autorId': autorId,
    };
  }
}

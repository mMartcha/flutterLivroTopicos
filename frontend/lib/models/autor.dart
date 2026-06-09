// Arquivo: lib/models/autor.dart
// O que faz: representa um Autor dentro do app (o "molde" dos dados do autor).
// Quando e usado: sempre que precisamos transformar o JSON que veio da API
// em um objeto Dart (fromJson) ou transformar o objeto de volta em JSON
// para enviar para a API (toJson).

class Autor {
  // Campos do autor. Sao "final" porque, depois de criado, o objeto nao muda.
  final int id; // gerado pela API
  final String nome; // obrigatorio
  final String nacionalidade; // obrigatorio

  // Construtor: usamos "const" porque os campos sao todos final.
  const Autor({
    required this.id,
    required this.nome,
    required this.nacionalidade,
  });

  // fromJson: cria um Autor a partir do Map que veio do JSON da API.
  // Ex.: {"id": 1, "nome": "Machado de Assis", "nacionalidade": "Brasileiro"}
  factory Autor.fromJson(Map<String, dynamic> json) {
    return Autor(
      id: json['id'] as int,
      nome: json['nome'] as String,
      nacionalidade: json['nacionalidade'] as String,
    );
  }

  // toJson: transforma o Autor em um Map para enviar no corpo das requisicoes.
  // Nao enviamos o 'id' porque a API gera o id no POST e usa o id da URL no PUT.
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'nacionalidade': nacionalidade,
    };
  }
}

// Arquivo: lib/services/livro_service.dart
// O que faz: concentra TODA a comunicacao com a API REST de livros.
// Quando e usado: as telas chamam estes metodos (listar, buscarPorId, criar,
// atualizar, deletar) sem precisar saber os detalhes de HTTP/JSON.

import 'dart:convert'; // jsonDecode / jsonEncode

import 'package:http/http.dart' as http;

import '../models/livro.dart';

// Excecao simples para erros vindos da API.
// Guardamos uma mensagem amigavel que as telas podem mostrar direto ao usuario.
class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class LivroService {
  // URL base da API.
  // ATENCAO ao rodar o app:
  // - No EMULADOR ANDROID use 'http://10.0.2.2:8080'
  //   (10.0.2.2 e o "localhost" do seu PC visto de dentro do emulador).
  // - No iOS, no NAVEGADOR (web) e no DESKTOP use 'http://localhost:8080'.
  static const String _urlBase = 'http://10.0.2.2:8080';

  // Rota dos livros, montada a partir da URL base.
  static const String _rotaLivros = '$_urlBase/livros';

  // GET /livros -> devolve a lista completa de livros.
  Future<List<Livro>> listar() async {
    // await espera a resposta da API sem travar o app.
    final resposta = await http.get(Uri.parse(_rotaLivros));

    if (resposta.statusCode != 200) {
      throw ApiException('Erro ao listar livros (status ${resposta.statusCode}).');
    }

    // jsonDecode transforma o texto JSON em estruturas Dart (aqui, uma List).
    final List<dynamic> listaJson = jsonDecode(resposta.body) as List<dynamic>;

    // Percorremos cada item e convertemos em objeto Livro.
    final List<Livro> livros = [];
    for (final item in listaJson) {
      livros.add(Livro.fromJson(item as Map<String, dynamic>));
    }
    return livros;
  }

  // GET /livros/{id} -> devolve um unico livro pelo id.
  Future<Livro> buscarPorId(int id) async {
    final resposta = await http.get(Uri.parse('$_rotaLivros/$id'));

    if (resposta.statusCode != 200) {
      throw ApiException('Erro ao buscar o livro (status ${resposta.statusCode}).');
    }

    final Map<String, dynamic> json =
        jsonDecode(resposta.body) as Map<String, dynamic>;
    return Livro.fromJson(json);
  }

  // POST /livros -> cria um novo livro.
  Future<void> criar(Livro livro) async {
    final resposta = await http.post(
      Uri.parse(_rotaLivros),
      headers: {'Content-Type': 'application/json'},
      // jsonEncode transforma o Map (toJson) em texto JSON para enviar.
      body: jsonEncode(livro.toJson()),
    );

    // Em criacao, a API normalmente responde 200 ou 201 (Created).
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw ApiException('Erro ao criar o livro (status ${resposta.statusCode}).');
    }
  }

  // PUT /livros/{id} -> atualiza um livro existente.
  Future<void> atualizar(Livro livro) async {
    final resposta = await http.put(
      Uri.parse('$_rotaLivros/${livro.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livro.toJson()),
    );

    if (resposta.statusCode != 200) {
      throw ApiException('Erro ao atualizar o livro (status ${resposta.statusCode}).');
    }
  }

  // DELETE /livros/{id} -> exclui um livro pelo id.
  Future<void> deletar(int id) async {
    final resposta = await http.delete(Uri.parse('$_rotaLivros/$id'));

    // Em exclusao, a API costuma responder 200 ou 204 (sem conteudo).
    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw ApiException('Erro ao excluir o livro (status ${resposta.statusCode}).');
    }
  }
}

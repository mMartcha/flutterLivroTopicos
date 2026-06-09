// Arquivo: lib/services/autor_service.dart
// O que faz: concentra TODA a comunicacao com a API REST de autores.
// Quando e usado: as telas de autor chamam estes metodos (listar, buscarPorId,
// criar, atualizar, deletar, listarLivrosDoAutor) sem precisar conhecer HTTP.

import 'dart:convert'; // jsonDecode / jsonEncode

import 'package:http/http.dart' as http;

import '../models/autor.dart';
import '../models/livro.dart';
import 'api_exception.dart';

class AutorService {
  // URL base da API.
  // ATENCAO ao rodar o app:
  // - No EMULADOR ANDROID use 'http://10.0.2.2:8080'
  //   (10.0.2.2 e o "localhost" do seu PC visto de dentro do emulador).
  // - No iOS, no NAVEGADOR (web) e no DESKTOP use 'http://localhost:8080'.
  static const String _urlBase = 'http://10.0.2.2:8080';

  // Rota dos autores, montada a partir da URL base.
  static const String _rotaAutores = '$_urlBase/autores';

  // GET /autores -> devolve a lista completa de autores.
  Future<List<Autor>> listar() async {
    final resposta = await http.get(Uri.parse(_rotaAutores));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao listar autores');
    }

    final List<dynamic> listaJson = jsonDecode(resposta.body) as List<dynamic>;

    final List<Autor> autores = [];
    for (final item in listaJson) {
      autores.add(Autor.fromJson(item as Map<String, dynamic>));
    }
    return autores;
  }

  // GET /autores/{id} -> devolve um unico autor pelo id.
  Future<Autor> buscarPorId(int id) async {
    final resposta = await http.get(Uri.parse('$_rotaAutores/$id'));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao buscar o autor');
    }

    final Map<String, dynamic> json =
        jsonDecode(resposta.body) as Map<String, dynamic>;
    return Autor.fromJson(json);
  }

  // GET /autores/{id}/livros -> devolve os livros daquele autor.
  // Usado na tela de detalhe do autor, na secao "Livros deste autor".
  Future<List<Livro>> listarLivrosDoAutor(int autorId) async {
    final resposta = await http.get(Uri.parse('$_rotaAutores/$autorId/livros'));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao listar os livros do autor');
    }

    final List<dynamic> listaJson = jsonDecode(resposta.body) as List<dynamic>;

    final List<Livro> livros = [];
    for (final item in listaJson) {
      livros.add(Livro.fromJson(item as Map<String, dynamic>));
    }
    return livros;
  }

  // POST /autores -> cria um novo autor.
  Future<void> criar(Autor autor) async {
    final resposta = await http.post(
      Uri.parse(_rotaAutores),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(autor.toJson()),
    );

    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw erroDaApi(resposta, 'Erro ao criar o autor');
    }
  }

  // PUT /autores/{id} -> atualiza um autor existente.
  Future<void> atualizar(Autor autor) async {
    final resposta = await http.put(
      Uri.parse('$_rotaAutores/${autor.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(autor.toJson()),
    );

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao atualizar o autor');
    }
  }

  // DELETE /autores/{id} -> exclui um autor pelo id.
  // Se o autor tiver livros, a API responde 409 com uma mensagem amigavel,
  // que o erroDaApi captura e a tela mostra num SnackBar vermelho.
  Future<void> deletar(int id) async {
    final resposta = await http.delete(Uri.parse('$_rotaAutores/$id'));

    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw erroDaApi(resposta, 'Erro ao excluir o autor');
    }
  }
}

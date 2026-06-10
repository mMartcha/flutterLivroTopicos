import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/autor.dart';
import '../models/livro.dart';
import 'api_exception.dart';

class AutorService {
  // ATENCAO ao rodar o app:
  // - No EMULADOR ANDROID use 'http://10.0.2.2:8080'
  //   (10.0.2.2 e o "localhost" do seu PC visto de dentro do emulador).
  // - No iOS, no NAVEGADOR (web) e no DESKTOP use 'http://localhost:8080'.
  static const String _urlBase = 'http://10.0.2.2:8080';

  static const String _rotaAutores = '$_urlBase/autores';

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

  Future<Autor> buscarPorId(int id) async {
    final resposta = await http.get(Uri.parse('$_rotaAutores/$id'));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao buscar o autor');
    }

    final Map<String, dynamic> json =
        jsonDecode(resposta.body) as Map<String, dynamic>;
    return Autor.fromJson(json);
  }

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

  Future<void> deletar(int id) async {
    final resposta = await http.delete(Uri.parse('$_rotaAutores/$id'));

    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw erroDaApi(resposta, 'Erro ao excluir o autor');
    }
  }
}

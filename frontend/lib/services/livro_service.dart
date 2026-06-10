import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/livro.dart';
import 'api_exception.dart';

class LivroService {
  // ATENCAO ao rodar o app:
  // - No EMULADOR ANDROID use 'http://10.0.2.2:8080'
  //   (10.0.2.2 e o "localhost" do seu PC visto de dentro do emulador).
  // - No iOS, no NAVEGADOR (web) e no DESKTOP use 'http://localhost:8080'.
  static const String _urlBase = 'http://10.0.2.2:8080';

  static const String _rotaLivros = '$_urlBase/livros';

  Future<List<Livro>> listar() async {
    final resposta = await http.get(Uri.parse(_rotaLivros));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao listar livros');
    }

    final List<dynamic> listaJson = jsonDecode(resposta.body) as List<dynamic>;

    final List<Livro> livros = [];
    for (final item in listaJson) {
      livros.add(Livro.fromJson(item as Map<String, dynamic>));
    }
    return livros;
  }

  Future<Livro> buscarPorId(int id) async {
    final resposta = await http.get(Uri.parse('$_rotaLivros/$id'));

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao buscar o livro');
    }

    final Map<String, dynamic> json =
        jsonDecode(resposta.body) as Map<String, dynamic>;
    return Livro.fromJson(json);
  }

  Future<void> criar(Livro livro) async {
    final resposta = await http.post(
      Uri.parse(_rotaLivros),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livro.toJson()),
    );

    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw erroDaApi(resposta, 'Erro ao criar o livro');
    }
  }

  Future<void> atualizar(Livro livro) async {
    final resposta = await http.put(
      Uri.parse('$_rotaLivros/${livro.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livro.toJson()),
    );

    if (resposta.statusCode != 200) {
      throw erroDaApi(resposta, 'Erro ao atualizar o livro');
    }
  }

  Future<void> deletar(int id) async {
    final resposta = await http.delete(Uri.parse('$_rotaLivros/$id'));

    if (resposta.statusCode != 200 && resposta.statusCode != 204) {
      throw erroDaApi(resposta, 'Erro ao excluir o livro');
    }
  }
}

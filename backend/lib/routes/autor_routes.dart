import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/autor.dart';
import '../repositories/autor_repository.dart';
import '../repositories/livro_repository.dart';
import '../utils/response.dart';

class AutorRoutes {
  final AutorRepository repository = AutorRepository();
  final LivroRepository livroRepository = LivroRepository();

  Router get router {
    final router = Router();

    router.get('/autores', _listarAutores);
    router.get('/autores/<id>/livros', _listarLivrosPorAutor);
    router.get('/autores/<id>', _buscarAutorPorId);
    router.post('/autores', _criarAutor);
    router.put('/autores/<id>', _atualizarAutor);
    router.delete('/autores/<id>', _removerAutor);

    return router;
  }

  Response _listarAutores(Request request) {
    final autores = repository.listar();

    return jsonResponse(
      autores.map((autor) => autor.toJson()).toList(),
    );
  }

  Response _buscarAutorPorId(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return jsonResponse(
        {'erro': 'ID invalido'},
        statusCode: 400,
      );
    }

    final autor = repository.buscarPorId(autorId);
    if (autor == null) {
      return jsonResponse(
        {'erro': 'Autor nao encontrado'},
        statusCode: 404,
      );
    }

    return jsonResponse(autor.toJson());
  }

  Response _listarLivrosPorAutor(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return jsonResponse(
        {'erro': 'ID invalido'},
        statusCode: 400,
      );
    }

    final autor = repository.buscarPorId(autorId);
    if (autor == null) {
      return jsonResponse(
        {'erro': 'Autor nao encontrado'},
        statusCode: 404,
      );
    }

    final livros = livroRepository.listarPorAutor(autorId);
    return jsonResponse(
      livros.map((livro) => livro.toJson()).toList(),
    );
  }

  Future<Response> _criarAutor(Request request) async {
    final data = await _lerBodyJson(request);
    if (data == null) {
      return jsonResponse(
        {'erro': 'Body invalido'},
        statusCode: 400,
      );
    }

    final nome = data['nome'];
    if (nome is! String || nome.trim().isEmpty) {
      return jsonResponse(
        {'erro': 'Campo obrigatorio: nome'},
        statusCode: 400,
      );
    }

    final autor = Autor(nome: nome.trim());
    final criado = repository.criar(autor);

    return jsonResponse(criado.toJson(), statusCode: 201);
  }

  Future<Response> _atualizarAutor(Request request, String id) async {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return jsonResponse(
        {'erro': 'ID invalido'},
        statusCode: 400,
      );
    }

    final data = await _lerBodyJson(request);
    if (data == null) {
      return jsonResponse(
        {'erro': 'Body invalido'},
        statusCode: 400,
      );
    }

    final nome = data['nome'];
    if (nome is! String || nome.trim().isEmpty) {
      return jsonResponse(
        {'erro': 'Campo obrigatorio: nome'},
        statusCode: 400,
      );
    }

    final autor = Autor(nome: nome.trim());
    final atualizado = repository.atualizar(autorId, autor);

    if (atualizado == null) {
      return jsonResponse(
        {'erro': 'Autor nao encontrado'},
        statusCode: 404,
      );
    }

    return jsonResponse(atualizado.toJson());
  }

  Response _removerAutor(Request request, String id) {
    final autorId = int.tryParse(id);
    if (autorId == null) {
      return jsonResponse(
        {'erro': 'ID invalido'},
        statusCode: 400,
      );
    }

    final autor = repository.buscarPorId(autorId);
    if (autor == null) {
      return jsonResponse(
        {'erro': 'Autor nao encontrado'},
        statusCode: 404,
      );
    }

    if (repository.possuiLivros(autorId)) {
      return jsonResponse(
        {'erro': 'Nao e possivel excluir autor com livros vinculados'},
        statusCode: 400,
      );
    }

    repository.remover(autorId);
    return emptyResponse(statusCode: 204);
  }

  Future<Map<String, dynamic>?> _lerBodyJson(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}

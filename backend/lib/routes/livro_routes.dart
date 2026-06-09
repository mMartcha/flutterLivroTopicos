import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/livro.dart';
import '../repositories/autor_repository.dart';
import '../repositories/livro_repository.dart';
import '../utils/response.dart';

class LivroRoutes {
  final LivroRepository repository = LivroRepository();
  final AutorRepository autorRepository = AutorRepository();

  Router get router {
    final router = Router();

    router.get('/livros', _listarLivros);
    router.get('/livros/<id>', _buscarLivroPorId);
    router.post('/livros', _criarLivro);
    router.put('/livros/<id>', _atualizarLivro);
    router.delete('/livros/<id>', _removerLivro);

    return router;
  }

  Response _listarLivros(Request request) {
    final livros = repository.listar();

    return jsonResponse(
      livros.map((livro) => livro.toJson()).toList(),
    );
  }

  Response _buscarLivroPorId(Request request, String id) {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return jsonResponse(
        {'error': 'ID invalido'},
        statusCode: 400,
      );
    }

    final livro = repository.buscarPorId(livroId);
    if (livro == null) {
      return jsonResponse(
        {'error': 'Livro nao encontrado'},
        statusCode: 404,
      );
    }

    return jsonResponse(livro.toJson());
  }

  Future<Response> _criarLivro(Request request) async {
    final data = await _lerBodyJson(request);
    if (data == null) {
      return jsonResponse(
        {'error': 'Body invalido'},
        statusCode: 400,
      );
    }

    final livro = _validarLivro(data);
    if (livro == null) {
      return jsonResponse(
        {'error': 'Campos obrigatorios: titulo, ano, autorId'},
        statusCode: 400,
      );
    }

    final autor = autorRepository.buscarPorId(livro.autorId);
    if (autor == null) {
      return jsonResponse(
        {'error': 'Autor informado nao existe'},
        statusCode: 400,
      );
    }

    final criado = repository.criar(livro);
    return jsonResponse(criado.toJson(), statusCode: 201);
  }

  Future<Response> _atualizarLivro(Request request, String id) async {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return jsonResponse(
        {'error': 'ID invalido'},
        statusCode: 400,
      );
    }

    final data = await _lerBodyJson(request);
    if (data == null) {
      return jsonResponse(
        {'error': 'Body invalido'},
        statusCode: 400,
      );
    }

    final livro = _validarLivro(data);
    if (livro == null) {
      return jsonResponse(
        {'error': 'Campos obrigatorios: titulo, ano, autorId'},
        statusCode: 400,
      );
    }

    final autor = autorRepository.buscarPorId(livro.autorId);
    if (autor == null) {
      return jsonResponse(
        {'error': 'Autor informado nao existe'},
        statusCode: 400,
      );
    }

    final atualizado = repository.atualizar(livroId, livro);

    if (atualizado == null) {
      return jsonResponse(
        {'error': 'Livro nao encontrado'},
        statusCode: 404,
      );
    }

    return jsonResponse(atualizado.toJson());
  }

  Response _removerLivro(Request request, String id) {
    final livroId = int.tryParse(id);
    if (livroId == null) {
      return jsonResponse(
        {'error': 'ID invalido'},
        statusCode: 400,
      );
    }

    final removido = repository.remover(livroId);

    if (!removido) {
      return jsonResponse(
        {'error': 'Livro nao encontrado'},
        statusCode: 404,
      );
    }

    return emptyResponse(statusCode: 204);
  }

  Livro? _validarLivro(Map<String, dynamic> data) {
    final titulo = data['titulo'];
    final ano = data['ano'];
    final autorId = data['autorId'];

    if (titulo is! String || titulo.trim().isEmpty) {
      return null;
    }

    if (ano is! int || autorId is! int) {
      return null;
    }

    return Livro(
      titulo: titulo.trim(),
      ano: ano,
      autorId: autorId,
    );
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

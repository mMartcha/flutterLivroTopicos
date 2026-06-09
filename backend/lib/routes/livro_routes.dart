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

    // ---------------------------------------------------------------------
    // REGRA DE NEGOCIO: o autorId precisa existir de verdade.
    // ---------------------------------------------------------------------
    // O livro (filho) so pode ser criado se o autor (pai) que ele referencia
    // realmente existir na tabela de autores. Isso protege a integridade
    // referencial: nao deixamos cadastrar um livro apontando para um autor
    // inexistente.
    // Aqui os campos JA estao bem formados (titulo/ano/autorId no tipo certo);
    // o que falha e uma REGRA DE NEGOCIO. Por isso usamos o status 422
    // (Unprocessable Entity), que significa "entendi os dados, mas eles
    // ferem uma regra" -- diferente do 400, que e para body/campos invalidos.
    final autor = autorRepository.buscarPorId(livro.autorId);
    if (autor == null) {
      return jsonResponse(
        {'error': 'O autor informado não existe.'},
        statusCode: 422,
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

    // Primeiro verificamos se o LIVRO que se quer atualizar realmente existe.
    // Se nao existir, devolvemos 404 (nao encontrado). Fazemos essa checagem
    // antes da regra do autor para que o 404 tenha prioridade sobre o 422.
    final existente = repository.buscarPorId(livroId);
    if (existente == null) {
      return jsonResponse(
        {'error': 'Livro nao encontrado'},
        statusCode: 404,
      );
    }

    // Depois aplicamos a mesma regra de negocio do POST: o autorId informado
    // precisa existir. Como os dados estao bem formados mas ferem uma regra,
    // o status correto e 422 (e nao 400).
    final autor = autorRepository.buscarPorId(livro.autorId);
    if (autor == null) {
      return jsonResponse(
        {'error': 'O autor informado não existe.'},
        statusCode: 422,
      );
    }

    final atualizado = repository.atualizar(livroId, livro);

    return jsonResponse(atualizado!.toJson());
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

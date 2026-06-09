// Arquivo: lib/services/api_exception.dart
// O que faz: define UMA classe de erro (ApiException) usada pelos services, e
// uma funcao auxiliar que le a mensagem amigavel que a API manda quando algo
// da errado.
// Quando e usado: os services lancam (throw) esse erro quando a API responde
// com um status de falha; as telas capturam (catch) e mostram a mensagem.

import 'dart:convert'; // jsonDecode

import 'package:http/http.dart' as http;

// Excecao simples para erros vindos da API.
// Guardamos uma mensagem amigavel que as telas podem mostrar direto ao usuario.
class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

// Monta um ApiException a partir da resposta de erro da API.
// A nossa API devolve os erros no formato JSON { "error": "texto amigavel" }.
// Ex.: ao tentar excluir um autor com livros, ela manda
//      { "error": "Não é possível excluir um autor que possui livros..." }.
// Esta funcao tenta pegar esse texto. Se por algum motivo nao conseguir ler o
// JSON, usamos uma mensagem padrao junto com o codigo de status (ex: 500).
ApiException erroDaApi(http.Response resposta, String mensagemPadrao) {
  try {
    final corpo = jsonDecode(resposta.body);
    if (corpo is Map && corpo['error'] is String) {
      return ApiException(corpo['error'] as String);
    }
  } catch (_) {
    // O corpo nao era um JSON valido: caimos na mensagem padrao abaixo.
  }
  return ApiException('$mensagemPadrao (status ${resposta.statusCode}).');
}

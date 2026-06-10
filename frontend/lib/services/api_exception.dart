import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

ApiException erroDaApi(http.Response resposta, String mensagemPadrao) {
  try {
    final corpo = jsonDecode(resposta.body);
    if (corpo is Map && corpo['error'] is String) {
      return ApiException(corpo['error'] as String);
    }
  } catch (_) {}
  return ApiException('$mensagemPadrao (status ${resposta.statusCode}).');
}

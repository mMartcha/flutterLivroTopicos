import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import '../lib/routes/autor_routes.dart';
import '../lib/routes/livro_routes.dart';
import '../lib/utils/response.dart';

Middleware corsHeaders() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type',
          },
        );
      }

      final response = await innerHandler(request);

      return response.change(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      );
    };
  };
}

void main() async {
  final autorRoutes = AutorRoutes();
  final livroRoutes = LivroRoutes();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(
        Cascade()
            .add(autorRoutes.router)
            .add(livroRoutes.router)
            .handler,
      );

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
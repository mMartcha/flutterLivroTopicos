import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import '../lib/routes/autor_routes.dart';
import '../lib/routes/livro_routes.dart';
import '../lib/utils/response.dart';

// ===========================================================================
// MIDDLEWARE DE CORS
// ---------------------------------------------------------------------------
// CORS (Cross-Origin Resource Sharing) e' uma regra de seguranca do navegador.
// Por padrao, o navegador BLOQUEIA quando uma pagina (ex: o app Flutter rodando
// no Chrome em http://localhost:xxxx) tenta chamar uma API que esta em outro
// endereco/porta (ex: nossa API em http://localhost:8080).
// Para o navegador liberar essas chamadas, a API precisa devolver alguns
// cabecalhos (headers) dizendo "pode pode pode, eu autorizo".
// E' exatamente isso que este middleware faz: adiciona esses headers em TODAS
// as respostas da nossa API.
// ===========================================================================

// Guardamos os headers de CORS numa unica variavel para nao repetir o codigo
// em dois lugares (na resposta normal e na resposta do tipo OPTIONS).
final Map<String, String> _headersCors = {
  // Quem pode chamar a API. O '*' significa "qualquer origem/site".
  'Access-Control-Allow-Origin': '*',
  // Quais metodos HTTP sao permitidos.
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  // Quais headers o navegador pode enviar na requisicao.
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
};

Middleware corsHeaders() {
  return (innerHandler) {
    return (request) async {
      // Antes de uma chamada "de verdade" (POST/PUT/DELETE), o navegador manda
      // automaticamente uma requisicao do tipo OPTIONS para perguntar se pode.
      // Isso e' chamado de "preflight". Respondemos 200 com os headers de CORS.
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _headersCors);
      }

      // Para as demais requisicoes (GET, POST, etc.), deixamos a rota processar
      // normalmente e DEPOIS anexamos os headers de CORS na resposta.
      final response = await innerHandler(request);

      return response.change(
        headers: {
          ...response.headers,
          ..._headersCors,
        },
      );
    };
  };
}

// ===========================================================================
// MIDDLEWARE DE TRATAMENTO DE ERROS (status 500)
// ---------------------------------------------------------------------------
// Se qualquer parte do codigo lancar uma excecao inesperada (ex: uma falha no
// banco de dados), por padrao o servidor responderia com um erro "feio" e sem
// JSON. Este middleware "abraca" o processamento com um try/catch: se algo der
// errado, devolvemos uma resposta 500 padronizada no formato { "error": ... }.
// ===========================================================================
Middleware tratadorDeErros() {
  return (innerHandler) {
    return (request) async {
      try {
        // Tenta processar a requisicao normalmente.
        return await innerHandler(request);
      } catch (e) {
        // Se caiu aqui, houve um erro inesperado. Avisamos no console para
        // ajudar a depurar e devolvemos um 500 em JSON para o cliente.
        print('Erro interno: $e');
        return jsonResponse(
          {'error': 'Erro interno no servidor'},
          statusCode: 500,
        );
      }
    };
  };
}

// ===========================================================================
// DESPACHANTE DE ROTAS
// ---------------------------------------------------------------------------
// Temos dois conjuntos de rotas: as de autores e as de livros. Precisamos
// decidir qual deles vai atender cada requisicao.
//
// Antes usavamos o "Cascade" do Shelf, mas ele tinha um problema: o Cascade
// considera QUALQUER resposta 404 como "esse router nao soube responder" e
// tenta o proximo. Assim, quando o router de autores devolvia um 404 legitimo
// ("Autor nao encontrado"), o Cascade passava a requisicao para o router de
// livros, que respondia com um 404 generico "Route not found". Ou seja, nossa
// mensagem de erro em JSON era perdida.
//
// A solucao abaixo e' simples e direta: olhamos o inicio da URL e escolhemos o
// router certo. Assim, cada router cuida do seu proprio 404 e a mensagem em
// JSON chega ao app Flutter. (Em Shelf, request.url.path NAO tem a barra
// inicial, por isso comparamos com 'autores' e 'livros' sem a '/'.)
// ===========================================================================
Handler despacharRotas(AutorRoutes autorRoutes, LivroRoutes livroRoutes) {
  return (Request request) {
    final caminho = request.url.path;

    // Se a URL comeca com "autores", usamos o router de autores.
    if (caminho == 'autores' || caminho.startsWith('autores/')) {
      return autorRoutes.router(request);
    }

    // Se a URL comeca com "livros", usamos o router de livros.
    if (caminho == 'livros' || caminho.startsWith('livros/')) {
      return livroRoutes.router(request);
    }

    // Nenhum dos dois: devolvemos um 404 padronizado em JSON.
    return jsonResponse(
      {'error': 'Rota nao encontrada'},
      statusCode: 404,
    );
  };
}

void main() async {
  final autorRoutes = AutorRoutes();
  final livroRoutes = LivroRoutes();

  // O Pipeline encadeia os middlewares. A ordem importa:
  // 1) logRequests  -> imprime no console cada requisicao recebida.
  // 2) corsHeaders  -> fica "por fora" para garantir que ATE as respostas de
  //                    erro 500 saiam com os headers de CORS.
  // 3) tratadorDeErros -> captura excecoes e devolve 500 em JSON.
  // No fim, o despachante escolhe o router certo conforme a URL.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(tratadorDeErros())
      .addHandler(
        despacharRotas(autorRoutes, livroRoutes),
      );

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
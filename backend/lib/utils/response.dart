import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(
  Object body, {
  int statusCode = 200,
}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

Response emptyResponse({
  int statusCode = 204,
}) {
  return Response(
    statusCode,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

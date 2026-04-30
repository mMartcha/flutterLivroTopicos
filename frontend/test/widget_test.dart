import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biblioteca_frontend/main.dart';

void main() {
  testWidgets('abre a tela de listagem de livros', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    expect(find.text('Livros'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

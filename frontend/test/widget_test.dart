import 'package:flutter_test/flutter_test.dart';

import 'package:biblioteca_frontend/main.dart';

void main() {
  testWidgets('abre a home da biblioteca', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Biblioteca inteligente'), findsOneWidget);
    expect(find.text('Autores'), findsOneWidget);
    expect(find.text('Livros'), findsOneWidget);
  });
}

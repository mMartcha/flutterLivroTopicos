import 'package:flutter_test/flutter_test.dart';

import 'package:biblioteca_frontend/main.dart';

void main() {
  testWidgets('abre a home do MindLib', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    expect(find.text('MindLib'), findsOneWidget);
    expect(find.text('Autores'), findsOneWidget);
    expect(find.text('Livros'), findsOneWidget);
  });
}

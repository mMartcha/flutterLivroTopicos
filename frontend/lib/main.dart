// Arquivo: lib/main.dart
// O que faz: e o ponto de partida do app. Configura o MaterialApp (tema, titulo)
// e define qual e a primeira tela a aparecer (a lista de livros).
// Quando e usado: a funcao main() roda automaticamente quando o app inicia.

import 'package:flutter/material.dart';

import 'screens/lista_page.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Primeira tela do app: a lista de livros.
      home: const ListaPage(),
    );
  }
}

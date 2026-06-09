// Arquivo: lib/main.dart
// O que faz: e o ponto de partida do app. Configura o MaterialApp (tema, titulo)
// e define qual e a primeira tela a aparecer (a HomePage).
// Quando e usado: a funcao main() roda automaticamente quando o app inicia.

import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BibliotecaApp());
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca',
      theme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      // Primeira tela do app: a HomePage, com os botoes de Autores e Livros.
      home: const HomePage(),
    );
  }
}

// Arquivo: lib/screens/home_page.dart
// O que faz: e a tela inicial do app. Mostra dois botoes grandes que levam
// para a lista de Autores e para a lista de Livros.
// Quando e usado: e a primeira tela que aparece quando o app abre.

import 'package:flutter/material.dart';

import 'lista_autores_page.dart';
import 'lista_livros_page.dart';

// StatelessWidget porque esta tela NAO muda com o tempo: ela so mostra
// dois botoes fixos. (Telas que mudam sozinhas usam StatefulWidget.)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botao grande "Autores".
            montarBotao(
              context: context,
              texto: 'Autores',
              icone: Icons.person,
              aoTocar: () {
                // Navigator.push abre a tela da lista de autores por cima desta.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaAutoresPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Botao grande "Livros".
            montarBotao(
              context: context,
              texto: 'Livros',
              icone: Icons.menu_book,
              aoTocar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaLivrosPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Monta um botao grande e alto, para reaproveitar o mesmo visual nos dois.
  Widget montarBotao({
    required BuildContext context,
    required String texto,
    required IconData icone,
    required VoidCallback aoTocar,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: ElevatedButton(
        onPressed: aoTocar,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 40),
            const SizedBox(height: 8),
            Text(texto, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

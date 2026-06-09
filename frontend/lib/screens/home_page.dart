// Arquivo: lib/screens/home_page.dart
// O que faz: e a tela inicial do app. Mostra dois botoes grandes que levam
// para a lista de Autores e para a lista de Livros.
// Quando e usado: e a primeira tela que aparece quando o app abre.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primarySoft,
                    size: 32,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Biblioteca inteligente',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie autores e livros em uma interface escura, direta e pronta para consulta.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            montarBotao(
              context: context,
              texto: 'Autores',
              icone: Icons.person,
              legenda: 'Cadastro, nacionalidade e livros vinculados',
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
            const SizedBox(height: 12),
            montarBotao(
              context: context,
              texto: 'Livros',
              icone: Icons.menu_book,
              legenda: 'Titulos, anos e seus autores',
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
    required String legenda,
    required VoidCallback aoTocar,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: AppColors.primarySoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texto,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      legenda,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

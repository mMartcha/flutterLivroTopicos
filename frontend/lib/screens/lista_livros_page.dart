import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import '../theme/app_theme.dart';
import 'detalhe_livro_page.dart';
import 'formulario_livro_page.dart';

class ListaLivrosPage extends StatefulWidget {
  const ListaLivrosPage({super.key});

  @override
  State<ListaLivrosPage> createState() => _ListaLivrosPageState();
}

class _ListaLivrosPageState extends State<ListaLivrosPage> {
  final LivroService servicoLivro = LivroService();
  final AutorService servicoAutor = AutorService();

  bool carregando = true;
  String? mensagemErro;
  List<Livro> livros = [];

  Map<int, String> nomePorAutorId = {};

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  // Junta livros e autores no app para exibir o nome do autor na lista.
  Future<void> buscarDados() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final listaLivros = await servicoLivro.listar();
      final listaAutores = await servicoAutor.listar();

      final Map<int, String> mapa = {};
      for (final Autor autor in listaAutores) {
        mapa[autor.id] = autor.nome;
      }

      setState(() {
        livros = listaLivros;
        nomePorAutorId = mapa;
        carregando = false;
      });
    } catch (erro) {
      setState(() {
        mensagemErro =
            'Nao foi possivel carregar os livros. Verifique a API e tente novamente.';
        carregando = false;
      });
    }
  }

  String nomeDoAutor(int autorId) {
    return nomePorAutorId[autorId] ?? 'Autor #$autorId';
  }

  void abrirCriacao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioLivroPage()),
    ).then((resultado) {
      if (resultado == true) {
        buscarDados();
      }
    });
  }

  void abrirDetalhe(Livro livro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheLivroPage(
          livro: livro,
          nomeAutor: nomeDoAutor(livro.autorId),
        ),
      ),
    ).then((_) {
      buscarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livros')),
      body: montarCorpo(),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriacao,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget montarCorpo() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: buscarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (livros.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum livro encontrado.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: livros.length,
      itemBuilder: (context, index) {
        final livro = livros[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book),
            ),
            title: Text(
              livro.titulo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Autor: ${nomeDoAutor(livro.autorId)}  |  Ano: ${livro.ano}',
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSoft,
            ),
            onTap: () => abrirDetalhe(livro),
          ),
        );
      },
    );
  }
}

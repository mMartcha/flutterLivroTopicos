// Arquivo: lib/screens/lista_livros_page.dart
// O que faz: lista todos os livros vindos da API, mostrando o NOME do autor
// (e nao o autorId cru).
// Quando e usado: aberta a partir da HomePage (botao "Livros"). Dela navegamos
// para o detalhe de um livro e para o formulario de criar um novo livro.

import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import 'detalhe_livro_page.dart';
import 'formulario_livro_page.dart';

class ListaLivrosPage extends StatefulWidget {
  const ListaLivrosPage({super.key});

  @override
  State<ListaLivrosPage> createState() => _ListaLivrosPageState();
}

class _ListaLivrosPageState extends State<ListaLivrosPage> {
  // Precisamos dos dois services: um para os livros e outro para os autores
  // (para descobrir o NOME do autor de cada livro).
  final LivroService servicoLivro = LivroService();
  final AutorService servicoAutor = AutorService();

  bool carregando = true;
  String? mensagemErro;
  List<Livro> livros = [];

  // "Tabela de consulta" autorId -> nome do autor.
  // Montamos esse Map ao carregar os autores para, na hora de desenhar a lista,
  // descobrir rapidamente o nome do autor de cada livro.
  Map<int, String> nomePorAutorId = {};

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  // Busca livros E autores na API e faz o "join" em memoria.
  // Numa app real isso normalmente seria um unico endpoint que ja devolve o
  // livro com o nome do autor junto; aqui juntamos no proprio app.
  Future<void> buscarDados() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      // Buscamos as duas listas (uma de cada vez, para ficar simples de entender).
      final listaLivros = await servicoLivro.listar();
      final listaAutores = await servicoAutor.listar();

      // Montamos o mapa autorId -> nome a partir da lista de autores.
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

  // Dado um autorId, devolve o nome do autor (ou um texto de fallback).
  String nomeDoAutor(int autorId) {
    return nomePorAutorId[autorId] ?? 'Autor #$autorId';
  }

  // Abre o formulario em modo CRIACAO (sem passar livro).
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

  // Abre a tela de detalhe passando o livro tocado e o nome do autor dele.
  void abrirDetalhe(Livro livro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheLivroPage(
          livro: livro,
          nomeAutor: nomeDoAutor(livro.autorId),
        ),
      ),
    ).then((resultado) {
      if (resultado == true) {
        buscarDados();
      }
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
                style: const TextStyle(fontSize: 16),
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
      return const Center(child: Text('Nenhum livro encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: livros.length,
      itemBuilder: (context, index) {
        final livro = livros[index];

        return Card(
          child: ListTile(
            title: Text(livro.titulo),
            // Mostramos o NOME do autor (e nao o autorId cru) + o ano.
            subtitle: Text('Autor: ${nomeDoAutor(livro.autorId)}  |  Ano: ${livro.ano}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => abrirDetalhe(livro),
          ),
        );
      },
    );
  }
}

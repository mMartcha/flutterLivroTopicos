// Arquivo: lib/screens/lista_page.dart
// O que faz: tela inicial que lista todos os livros vindos da API.
// Quando e usado: e a primeira tela do app; a partir dela navegamos para os
// detalhes de um livro e para o formulario de criar um novo livro.

import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/livro_service.dart';
import 'detalhe_page.dart';
import 'formulario_page.dart';

// StatefulWidget porque o conteudo da tela MUDA com o tempo
// (carregando -> lista carregada -> ou erro).
class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  // Instanciamos o service direto aqui (sem injecao de dependencia).
  final LivroService servico = LivroService();

  // Variaveis de estado da tela.
  bool carregando = true;
  String? mensagemErro;
  List<Livro> livros = [];

  @override
  void initState() {
    super.initState();
    // initState roda UMA vez, quando a tela e criada. Aproveitamos para a 1a busca.
    buscarLivros();
  }

  // Busca a lista de livros na API e atualiza a tela.
  Future<void> buscarLivros() async {
    // setState avisa o Flutter para redesenhar a tela com os novos valores.
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      // await espera a resposta da API sem travar o app.
      final lista = await servico.listar();
      setState(() {
        livros = lista;
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

  // Abre o formulario em modo CRIACAO (sem passar livro).
  void abrirCriacao() {
    // Navigator.push abre uma nova tela por cima da atual.
    // O .then(...) roda QUANDO voltamos dessa tela; usamos para recarregar a lista.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioPage()),
    ).then((resultado) {
      // Se o formulario retornou true (salvou), recarregamos a lista.
      if (resultado == true) {
        buscarLivros();
      }
    });
  }

  // Abre a tela de detalhe passando o livro tocado.
  void abrirDetalhe(Livro livro) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalhePage(livro: livro)),
    ).then((resultado) {
      // Voltou do detalhe (pode ter editado ou excluido) -> recarrega.
      if (resultado == true) {
        buscarLivros();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livros')),
      body: montarCorpo(),
      // Botao "+" para criar um novo livro.
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriacao,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Decide o que mostrar na tela: loading, erro, lista vazia ou a lista.
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
              // Botao para tentar carregar de novo.
              ElevatedButton(
                onPressed: buscarLivros,
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

    // ListView.builder monta a lista item por item (eficiente para listas grandes).
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: livros.length,
      itemBuilder: (context, index) {
        final livro = livros[index];

        return Card(
          child: ListTile(
            title: Text(livro.titulo),
            subtitle: Text('Ano: ${livro.ano}  |  Autor ID: ${livro.autorId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => abrirDetalhe(livro),
          ),
        );
      },
    );
  }
}

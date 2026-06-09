// Arquivo: lib/screens/detalhe_livro_page.dart
// O que faz: mostra todos os dados de um livro (incluindo o NOME do autor) e
// permite editar ou excluir.
// Quando e usado: ao tocar em um livro na tela de lista de livros.

import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import 'formulario_livro_page.dart';

class DetalheLivroPage extends StatefulWidget {
  // Recebe o livro a ser exibido e o nome do autor (que a lista ja descobriu).
  final Livro livro;
  final String nomeAutor;

  const DetalheLivroPage({
    super.key,
    required this.livro,
    required this.nomeAutor,
  });

  @override
  State<DetalheLivroPage> createState() => _DetalheLivroPageState();
}

class _DetalheLivroPageState extends State<DetalheLivroPage> {
  final LivroService servico = LivroService();
  final AutorService servicoAutor = AutorService();

  // Guardamos o livro e o nome do autor no State para poder atualiza-los
  // depois de uma edicao.
  late Livro livro;
  late String nomeAutor;

  // Controla o loading enquanto a exclusao acontece.
  bool excluindo = false;

  @override
  void initState() {
    super.initState();
    livro = widget.livro;
    nomeAutor = widget.nomeAutor;
  }

  // Abre o formulario em modo EDICAO (passando o livro atual).
  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioLivroPage(livro: livro)),
    ).then((resultado) async {
      // Se salvou a edicao, buscamos o livro atualizado na API e redesenhamos.
      if (resultado == true) {
        try {
          final atualizado = await servico.buscarPorId(livro.id);
          // O autor pode ter mudado na edicao, entao buscamos o nome de novo.
          final autor = await servicoAutor.buscarPorId(atualizado.autorId);
          setState(() {
            livro = atualizado;
            nomeAutor = autor.nome;
          });
        } catch (erro) {
          mostrarMensagem(
            'Editado, mas nao foi possivel recarregar os dados.',
            Colors.red,
          );
        }
      }
    });
  }

  // Mostra o dialogo de confirmacao antes de excluir.
  void confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusao'),
          content: const Text('Tem certeza que deseja excluir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // so fecha o dialogo
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha o dialogo
                excluir(); // executa a exclusao de fato
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Chama o DELETE na API e volta para a lista.
  Future<void> excluir() async {
    setState(() {
      excluindo = true;
    });

    try {
      await servico.deletar(livro.id);

      if (!mounted) return;
      mostrarMensagem('Livro excluido com sucesso!', Colors.green);

      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        excluindo = false;
      });
      mostrarMensagem(erro.toString(), Colors.red);
    }
  }

  // Mostra um SnackBar (mensagem rapida na parte de baixo da tela).
  void mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Livro'),
        actions: [
          IconButton(
            onPressed: abrirEdicao,
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: confirmarExclusao,
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
          ),
        ],
      ),
      body: excluindo
          ? const Center(child: CircularProgressIndicator())
          : montarDetalhes(),
    );
  }

  // Monta a area com todos os campos do livro.
  Widget montarDetalhes() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          montarLinha('ID', '${livro.id}'),
          const Divider(),
          montarLinha('Titulo', livro.titulo),
          const Divider(),
          montarLinha('Ano', '${livro.ano}'),
          const Divider(),
          // Mostramos o NOME do autor (e nao o autorId cru).
          montarLinha('Autor', nomeAutor),
        ],
      ),
    );
  }

  // Monta uma linha "Rotulo: valor" para reaproveitar no layout.
  Widget montarLinha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$rotulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

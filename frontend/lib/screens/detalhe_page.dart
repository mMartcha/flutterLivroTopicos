// Arquivo: lib/screens/detalhe_page.dart
// O que faz: mostra todos os dados de um livro e permite editar ou excluir.
// Quando e usado: ao tocar em um livro na tela de lista.

import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/livro_service.dart';
import 'formulario_page.dart';

class DetalhePage extends StatefulWidget {
  // Recebe o livro a ser exibido pelo construtor (vindo da lista).
  final Livro livro;

  const DetalhePage({super.key, required this.livro});

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  final LivroService servico = LivroService();

  // Guardamos o livro em uma variavel do State para poder atualiza-lo
  // depois de uma edicao. (O valor recebido fica em widget.livro.)
  late Livro livro;

  // Controla o loading enquanto a exclusao acontece.
  bool excluindo = false;

  @override
  void initState() {
    super.initState();
    livro = widget.livro;
  }

  // Abre o formulario em modo EDICAO (passando o livro atual).
  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioPage(livro: livro)),
    ).then((resultado) async {
      // Se salvou a edicao, buscamos o livro atualizado na API e redesenhamos.
      if (resultado == true) {
        try {
          final atualizado = await servico.buscarPorId(livro.id);
          setState(() {
            livro = atualizado;
          });
        } catch (erro) {
          // Se nao conseguir recarregar, ao menos avisamos.
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
    // showDialog abre uma janela (AlertDialog) por cima da tela.
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
              // Texto em vermelho para destacar que e uma acao perigosa.
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

      // mounted confirma que a tela ainda esta na tela antes de usar o context.
      if (!mounted) return;
      mostrarMensagem('Livro excluido com sucesso!', Colors.green);

      // Volta para a lista enviando "true" para ela recarregar.
      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        excluindo = false;
      });
      mostrarMensagem('Erro ao excluir: $erro', Colors.red);
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
          // Acao 1: editar (lapis).
          IconButton(
            onPressed: abrirEdicao,
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
          ),
          // Acao 2: excluir (lixeira).
          IconButton(
            onPressed: confirmarExclusao,
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
          ),
        ],
      ),
      // Enquanto exclui, mostra o loading; senao, mostra os detalhes.
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
          montarLinha('Autor ID', '${livro.autorId}'),
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

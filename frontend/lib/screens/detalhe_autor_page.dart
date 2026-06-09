// Arquivo: lib/screens/detalhe_autor_page.dart
// O que faz: mostra todos os dados de um autor, a lista de livros dele, e
// permite editar ou excluir o autor.
// Quando e usado: ao tocar em um autor na tela de lista de autores.

import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../theme/app_theme.dart';
import 'formulario_autor_page.dart';

class DetalheAutorPage extends StatefulWidget {
  // Recebe o autor a ser exibido pelo construtor (vindo da lista).
  final Autor autor;

  const DetalheAutorPage({super.key, required this.autor});

  @override
  State<DetalheAutorPage> createState() => _DetalheAutorPageState();
}

class _DetalheAutorPageState extends State<DetalheAutorPage> {
  final AutorService servico = AutorService();

  // Guardamos o autor numa variavel do State para poder atualiza-lo depois de
  // uma edicao. (O valor recebido fica em widget.autor.)
  late Autor autor;

  // Estado da secao "Livros deste autor".
  bool carregandoLivros = true;
  String? erroLivros;
  List<Livro> livrosDoAutor = [];

  // Controla o loading enquanto a exclusao acontece.
  bool excluindo = false;

  @override
  void initState() {
    super.initState();
    autor = widget.autor;
    // Ao abrir a tela, ja buscamos os livros deste autor.
    buscarLivrosDoAutor();
  }

  // Busca na API os livros que pertencem a este autor (GET /autores/{id}/livros).
  Future<void> buscarLivrosDoAutor() async {
    setState(() {
      carregandoLivros = true;
      erroLivros = null;
    });

    try {
      final lista = await servico.listarLivrosDoAutor(autor.id);
      setState(() {
        livrosDoAutor = lista;
        carregandoLivros = false;
      });
    } catch (erro) {
      setState(() {
        erroLivros = 'Nao foi possivel carregar os livros deste autor.';
        carregandoLivros = false;
      });
    }
  }

  // Abre o formulario em modo EDICAO (passando o autor atual).
  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FormularioAutorPage(autor: autor)),
    ).then((resultado) async {
      // Se salvou a edicao, buscamos o autor atualizado na API e redesenhamos.
      if (resultado == true) {
        try {
          final atualizado = await servico.buscarPorId(autor.id);
          setState(() {
            autor = atualizado;
          });
        } catch (erro) {
          mostrarMensagem(
            'Editado, mas nao foi possivel recarregar os dados.',
            AppColors.danger,
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
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.danger),
              ),
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
      await servico.deletar(autor.id);

      // mounted confirma que a tela ainda esta na tela antes de usar o context.
      if (!mounted) return;
      mostrarMensagem('Autor excluido com sucesso!', AppColors.success);

      // Volta para a lista enviando "true" para ela recarregar.
      Navigator.pop(context, true);
    } catch (erro) {
      // Se o autor tiver livros, a API responde 409 e o erro.toString() ja traz
      // a mensagem amigavel ("Não é possível excluir um autor que possui...").
      setState(() {
        excluindo = false;
      });
      mostrarMensagem(erro.toString(), AppColors.danger);
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
        title: const Text('Detalhes do Autor'),
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

  // Monta a area com todos os campos do autor + a secao de livros.
  Widget montarDetalhes() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person,
                color: AppColors.primarySoft,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                autor.nome,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              montarLinha('ID', '${autor.id}'),
              const Divider(),
              montarLinha('Nome', autor.nome),
              const Divider(),
              montarLinha('Nacionalidade', autor.nacionalidade),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Titulo da secao de livros.
        const Text(
          'Livros deste autor',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),

        // Conteudo da secao de livros (loading, erro, vazio ou lista).
        montarSecaoLivros(),
      ],
    );
  }

  // Decide o que mostrar na secao "Livros deste autor".
  Widget montarSecaoLivros() {
    if (carregandoLivros) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erroLivros != null) {
      return Text(
        erroLivros!,
        style: const TextStyle(color: AppColors.danger),
      );
    }

    if (livrosDoAutor.isEmpty) {
      return const Text(
        'Este autor ainda não tem livros cadastrados.',
        style: TextStyle(color: AppColors.textMuted),
      );
    }

    // Aqui a lista e SO LEITURA: nao tem botoes de editar/excluir.
    // Como esta dentro de um ListView, usamos um Column simples para os itens.
    return Column(
      children: livrosDoAutor.map((livro) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(
              livro.titulo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Ano: ${livro.ano}'),
          ),
        );
      }).toList(),
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
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

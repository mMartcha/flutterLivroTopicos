import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../theme/app_theme.dart';
import 'formulario_autor_page.dart';

class DetalheAutorPage extends StatefulWidget {
  final Autor autor;

  const DetalheAutorPage({super.key, required this.autor});

  @override
  State<DetalheAutorPage> createState() => _DetalheAutorPageState();
}

class _DetalheAutorPageState extends State<DetalheAutorPage> {
  final AutorService servico = AutorService();

  late Autor autor;

  bool carregandoLivros = true;
  String? erroLivros;
  List<Livro> livrosDoAutor = [];

  bool excluindo = false;

  @override
  void initState() {
    super.initState();
    autor = widget.autor;
    buscarLivrosDoAutor();
  }

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

  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FormularioAutorPage(autor: autor)),
    ).then((resultado) async {
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

  void confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusao'),
          content: const Text('Tem certeza que deseja excluir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                excluir();
              },
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

  Future<void> excluir() async {
    setState(() {
      excluindo = true;
    });

    try {
      await servico.deletar(autor.id);

      if (!mounted) return;
      mostrarMensagem('Autor excluido com sucesso!', AppColors.success);

      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        excluindo = false;
      });
      mostrarMensagem(erro.toString(), AppColors.danger);
    }
  }

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
        const Text(
          'Livros deste autor',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        montarSecaoLivros(),
      ],
    );
  }

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

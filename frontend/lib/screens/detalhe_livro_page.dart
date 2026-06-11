import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import '../theme/app_theme.dart';
import 'detalhe_autor_page.dart';
import 'formulario_livro_page.dart';

class DetalheLivroPage extends StatefulWidget {
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

  late Livro livro;
  late String nomeAutor;

  bool excluindo = false;
  bool abrindoAutor = false;

  @override
  void initState() {
    super.initState();
    livro = widget.livro;
    nomeAutor = widget.nomeAutor;
  }

  void abrirEdicao() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FormularioLivroPage(livro: livro)),
    ).then((resultado) async {
      if (resultado == true) {
        try {
          final atualizado = await servico.buscarPorId(livro.id);
          final autor = await servicoAutor.buscarPorId(atualizado.autorId);
          setState(() {
            livro = atualizado;
            nomeAutor = autor.nome;
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

  Future<void> abrirDetalheAutor() async {
    setState(() {
      abrindoAutor = true;
    });

    try {
      final autor = await servicoAutor.buscarPorId(livro.autorId);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalheAutorPage(autor: autor),
        ),
      ).then((_) async {
        try {
          final atualizado = await servico.buscarPorId(livro.id);
          final autorAtualizado =
              await servicoAutor.buscarPorId(atualizado.autorId);

          if (!mounted) return;
          setState(() {
            livro = atualizado;
            nomeAutor = autorAtualizado.nome;
          });
        } catch (_) {}
      });
    } catch (erro) {
      mostrarMensagem(erro.toString(), AppColors.danger);
    } finally {
      if (mounted) {
        setState(() {
          abrindoAutor = false;
        });
      }
    }
  }

  Future<void> excluir() async {
    setState(() {
      excluindo = true;
    });

    try {
      await servico.deletar(livro.id);

      if (!mounted) return;
      mostrarMensagem('Livro excluido com sucesso!', AppColors.success);

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

  Widget montarDetalhes() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
              Icons.menu_book,
              color: AppColors.primarySoft,
              size: 34,
            ),
            const SizedBox(height: 14),
            Text(
              livro.titulo,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            montarLinha('ID', '${livro.id}'),
            const Divider(),
            montarLinha('Titulo', livro.titulo),
            const Divider(),
            montarLinha('Ano', '${livro.ano}'),
            const Divider(),
            montarAutor(),
          ],
        ),
      ),
    );
  }

  Widget montarAutor() {
    return Material(
      color: AppColors.chip,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: abrindoAutor ? null : abrirDetalheAutor,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Autor',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nomeAutor,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              abrindoAutor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSoft,
                    ),
            ],
          ),
        ),
      ),
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

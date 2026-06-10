import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../services/autor_service.dart';
import '../theme/app_theme.dart';
import 'detalhe_autor_page.dart';
import 'formulario_autor_page.dart';

class ListaAutoresPage extends StatefulWidget {
  const ListaAutoresPage({super.key});

  @override
  State<ListaAutoresPage> createState() => _ListaAutoresPageState();
}

class _ListaAutoresPageState extends State<ListaAutoresPage> {
  final AutorService servico = AutorService();

  bool carregando = true;
  String? mensagemErro;
  List<Autor> autores = [];

  @override
  void initState() {
    super.initState();
    buscarAutores();
  }

  Future<void> buscarAutores() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final lista = await servico.listar();
      setState(() {
        autores = lista;
        carregando = false;
      });
    } catch (erro) {
      setState(() {
        mensagemErro =
            'Nao foi possivel carregar os autores. Verifique a API e tente novamente.';
        carregando = false;
      });
    }
  }

  void abrirCriacao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioAutorPage()),
    ).then((resultado) {
      if (resultado == true) {
        buscarAutores();
      }
    });
  }

  void abrirDetalhe(Autor autor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalheAutorPage(autor: autor)),
    ).then((_) {
      buscarAutores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autores')),
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
                onPressed: buscarAutores,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (autores.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum autor encontrado.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: autores.length,
      itemBuilder: (context, index) {
        final autor = autores[index];

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
              child: const Icon(Icons.person),
            ),
            title: Text(
              autor.nome,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Nacionalidade: ${autor.nacionalidade}'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSoft,
            ),
            onTap: () => abrirDetalhe(autor),
          ),
        );
      },
    );
  }
}

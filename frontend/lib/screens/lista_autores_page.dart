// Arquivo: lib/screens/lista_autores_page.dart
// O que faz: lista todos os autores vindos da API.
// Quando e usado: aberta a partir da HomePage (botao "Autores"). Dela navegamos
// para o detalhe de um autor e para o formulario de criar um novo autor.

import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../services/autor_service.dart';
import '../theme/app_theme.dart';
import 'detalhe_autor_page.dart';
import 'formulario_autor_page.dart';

// StatefulWidget porque o conteudo da tela MUDA com o tempo
// (carregando -> lista carregada -> ou erro).
class ListaAutoresPage extends StatefulWidget {
  const ListaAutoresPage({super.key});

  @override
  State<ListaAutoresPage> createState() => _ListaAutoresPageState();
}

class _ListaAutoresPageState extends State<ListaAutoresPage> {
  // Instanciamos o service direto aqui (sem injecao de dependencia).
  final AutorService servico = AutorService();

  // Variaveis de estado da tela.
  bool carregando = true;
  String? mensagemErro;
  List<Autor> autores = [];

  @override
  void initState() {
    super.initState();
    // initState roda UMA vez, quando a tela e criada. Aproveitamos para a 1a busca.
    buscarAutores();
  }

  // Busca a lista de autores na API e atualiza a tela.
  Future<void> buscarAutores() async {
    // setState avisa o Flutter para redesenhar a tela com os novos valores.
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      // await espera a resposta da API sem travar o app.
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

  // Abre o formulario em modo CRIACAO (sem passar autor).
  void abrirCriacao() {
    // Navigator.push abre uma nova tela por cima da atual.
    // O .then(...) roda QUANDO voltamos dessa tela; usamos para recarregar a lista.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormularioAutorPage()),
    ).then((resultado) {
      // Se o formulario retornou true (salvou), recarregamos a lista.
      if (resultado == true) {
        buscarAutores();
      }
    });
  }

  // Abre a tela de detalhe passando o autor tocado.
  void abrirDetalhe(Autor autor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalheAutorPage(autor: autor)),
    ).then((resultado) {
      // Voltou do detalhe (pode ter editado ou excluido) -> recarrega.
      if (resultado == true) {
        buscarAutores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autores')),
      body: montarCorpo(),
      // Botao "+" para criar um novo autor.
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
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Botao para tentar carregar de novo.
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

    // ListView.builder monta a lista item por item (eficiente para listas grandes).
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/livro.dart';

class LivroListPage extends StatefulWidget {
  const LivroListPage({super.key});

  @override
  State<LivroListPage> createState() => _LivroListPageState();
}

class _LivroListPageState extends State<LivroListPage> {
  // Para emulador Android, troque para: http://10.0.2.2:8080/livros
  static const String _livrosUrl = 'http://localhost:8080/livros';

  bool _carregando = true;
  String? _erro;
  List<Livro> _livros = const [];

  @override
  void initState() {
    super.initState();
    _buscarLivros();
  }

  Future<void> _buscarLivros() async {
    try {
      final response = await http.get(Uri.parse(_livrosUrl));

      if (response.statusCode != 200) {
        throw Exception('Status ${response.statusCode}');
      }

      final dados = jsonDecode(response.body) as List<dynamic>;
      final livros = dados
          .map((item) => Livro.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _livros = livros;
        _erro = null;
        _carregando = false;
      });
    } catch (_) {
      setState(() {
        _erro = 'Nao foi possivel carregar os livros. Verifique a API e tente novamente.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _erro!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (_livros.isEmpty) {
      return const Center(
        child: Text('Nenhum livro encontrado.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _livros.length,
      itemBuilder: (context, index) {
        final livro = _livros[index];

        return Card(
          child: ListTile(
            title: Text(livro.titulo),
            subtitle: Text('Ano: ${livro.ano} | Autor ID: ${livro.autorId}'),
          ),
        );
      },
    );
  }
}

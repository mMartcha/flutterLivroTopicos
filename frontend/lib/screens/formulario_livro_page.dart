import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';
import '../theme/app_theme.dart';

class FormularioLivroPage extends StatefulWidget {
  final Livro? livro;

  const FormularioLivroPage({super.key, this.livro});

  @override
  State<FormularioLivroPage> createState() => _FormularioLivroPageState();
}

class _FormularioLivroPageState extends State<FormularioLivroPage> {
  final LivroService servico = LivroService();
  final AutorService servicoAutor = AutorService();

  final GlobalKey<FormState> chaveFormulario = GlobalKey<FormState>();

  final TextEditingController controllerTitulo = TextEditingController();
  final TextEditingController controllerAno = TextEditingController();

  int? autorIdSelecionado;

  List<Autor> autores = [];

  bool carregandoAutores = true;
  String? erroAutores;

  bool salvando = false;

  bool get modoEdicao => widget.livro != null;

  @override
  void initState() {
    super.initState();

    if (modoEdicao) {
      controllerTitulo.text = widget.livro!.titulo;
      controllerAno.text = widget.livro!.ano.toString();
      autorIdSelecionado = widget.livro!.autorId;
    }

    buscarAutores();
  }

  Future<void> buscarAutores() async {
    setState(() {
      carregandoAutores = true;
      erroAutores = null;
    });

    try {
      final lista = await servicoAutor.listar();
      setState(() {
        autores = lista;
        carregandoAutores = false;
      });
    } catch (erro) {
      setState(() {
        erroAutores = 'Nao foi possivel carregar os autores.';
        carregandoAutores = false;
      });
    }
  }

  @override
  void dispose() {
    controllerTitulo.dispose();
    controllerAno.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    final livroDigitado = Livro(
      id: modoEdicao ? widget.livro!.id : 0,
      titulo: controllerTitulo.text.trim(),
      ano: int.parse(controllerAno.text),
      autorId: autorIdSelecionado!,
    );

    try {
      if (modoEdicao) {
        await servico.atualizar(livroDigitado);
      } else {
        await servico.criar(livroDigitado);
      }

      if (!mounted) return;
      mostrarMensagem(
        modoEdicao ? 'Atualizado com sucesso' : 'Criado com sucesso',
        AppColors.success,
      );

      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        salvando = false;
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
        title: Text(modoEdicao ? 'Editar Livro' : 'Novo Livro'),
      ),
      body: montarCorpo(),
    );
  }

  Widget montarCorpo() {
    if (carregandoAutores) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erroAutores != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                erroAutores!,
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

    return montarFormulario();
  }

  Widget montarFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Form(
          key: chaveFormulario,
          child: ListView(
            children: [
              const Text(
                'Dados do livro',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllerTitulo,
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o titulo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controllerAno,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  final anoAtual = DateTime.now().year;
                  final ano = int.tryParse(texto);

                  if (texto.isEmpty) {
                    return 'Informe o ano';
                  }
                  if (ano == null) {
                    return 'Ano deve ser um numero inteiro';
                  }
                  if (texto.length != 4) {
                    return 'Ano deve ter 4 digitos';
                  }
                  if (ano >= anoAtual) {
                    return 'Ano deve ser menor que $anoAtual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: autorIdSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: autores.map((autor) {
                  return DropdownMenuItem<int>(
                    value: autor.id,
                    child: Text(autor.nome),
                  );
                }).toList(),
                onChanged: (novoValor) {
                  setState(() {
                    autorIdSelecionado = novoValor;
                  });
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Selecione um autor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: salvando ? null : salvar,
                child: salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: salvando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

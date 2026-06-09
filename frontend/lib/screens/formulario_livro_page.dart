// Arquivo: lib/screens/formulario_livro_page.dart
// O que faz: formulario UNICO que serve para CRIAR e tambem para EDITAR um livro.
// O campo do autor e um DropdownButtonFormField (lista de nomes), e nao um campo
// de texto, para o usuario so conseguir escolher um autor que existe de verdade.
// Quando e usado: ao tocar no "+" na lista de livros (modo criacao) ou no lapis
// na tela de detalhe do livro (modo edicao).

import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../models/livro.dart';
import '../services/autor_service.dart';
import '../services/livro_service.dart';

class FormularioLivroPage extends StatefulWidget {
  // Parametro OPCIONAL:
  // - se vier null      -> modo CRIACAO
  // - se vier um livro  -> modo EDICAO
  final Livro? livro;

  const FormularioLivroPage({super.key, this.livro});

  @override
  State<FormularioLivroPage> createState() => _FormularioLivroPageState();
}

class _FormularioLivroPageState extends State<FormularioLivroPage> {
  final LivroService servico = LivroService();
  final AutorService servicoAutor = AutorService();

  // GlobalKey<FormState>: e o "controle remoto" do Form.
  // Usamos para mandar o formulario validar todos os campos de uma vez.
  final GlobalKey<FormState> chaveFormulario = GlobalKey<FormState>();

  // TextEditingController: controla o texto de cada campo de texto.
  // Com ele conseguimos LER o que o usuario digitou e tambem PRE-PREENCHER.
  final TextEditingController controllerTitulo = TextEditingController();
  final TextEditingController controllerAno = TextEditingController();

  // O autor NAO usa controller: ele e um dropdown. Guardamos aqui o id do autor
  // que esta selecionado no momento (null = nenhum selecionado ainda).
  int? autorIdSelecionado;

  // Lista de autores que vamos mostrar no dropdown. Buscada na API ao abrir.
  List<Autor> autores = [];

  // Estado do carregamento inicial dos autores (antes de mostrar o form).
  bool carregandoAutores = true;
  String? erroAutores;

  // Trava o botao Salvar enquanto a requisicao de salvar esta em andamento.
  bool salvando = false;

  // Diz se estamos editando (true) ou criando (false).
  bool get modoEdicao => widget.livro != null;

  @override
  void initState() {
    super.initState();

    // Se for edicao, preenchemos os campos de texto com os valores do livro.
    if (modoEdicao) {
      controllerTitulo.text = widget.livro!.titulo;
      controllerAno.text = widget.livro!.ano.toString();
      // Ja deixamos o autor do livro pre-selecionado no dropdown.
      autorIdSelecionado = widget.livro!.autorId;
    }

    // Buscamos a lista de autores ANTES de exibir o formulario, porque o
    // dropdown precisa dela para montar as opcoes.
    buscarAutores();
  }

  // Busca os autores na API (para preencher o dropdown).
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
    // dispose libera os controllers da memoria quando a tela e fechada.
    // Se esquecermos disso, o app fica vazando memoria (memory leak).
    controllerTitulo.dispose();
    controllerAno.dispose();
    super.dispose();
  }

  // Valida o formulario e envia para a API (POST se criar, PUT se editar).
  Future<void> salvar() async {
    // validate() roda os validators de cada campo (inclusive o do dropdown).
    if (!chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true; // trava o botao para evitar envio duplicado
    });

    // Monta o objeto Livro com o que foi digitado/selecionado.
    // No modo criacao o id ainda nao existe, entao usamos 0 (a API gera o real).
    final livroDigitado = Livro(
      id: modoEdicao ? widget.livro!.id : 0,
      titulo: controllerTitulo.text.trim(),
      ano: int.parse(controllerAno.text),
      autorId: autorIdSelecionado!, // o validator garante que nao e null aqui
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
        Colors.green,
      );

      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        salvando = false; // libera o botao de novo
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
        title: Text(modoEdicao ? 'Editar Livro' : 'Novo Livro'),
      ),
      body: montarCorpo(),
    );
  }

  // Enquanto os autores carregam, mostramos um loading central. So depois
  // exibimos o formulario (pois o dropdown depende da lista de autores).
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
                style: const TextStyle(fontSize: 16),
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

  // Monta o formulario com os 3 campos: titulo, ano e o dropdown de autor.
  Widget montarFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: chaveFormulario,
        child: ListView(
          children: [
            // Campo Titulo (obrigatorio).
            TextFormField(
              controller: controllerTitulo,
              decoration: const InputDecoration(labelText: 'Titulo'),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o titulo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Campo Ano (obrigatorio, precisa ser numero inteiro).
            TextFormField(
              controller: controllerAno,
              decoration: const InputDecoration(labelText: 'Ano'),
              keyboardType: TextInputType.number,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o ano';
                }
                if (int.tryParse(valor) == null) {
                  return 'Ano deve ser um numero inteiro';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Campo Autor: um DropdownButtonFormField<int>.
            // Cada opcao (DropdownMenuItem) guarda o id do autor como "value" e
            // mostra o nome dele para o usuario. O <int> diz que o valor
            // escolhido e um id (numero) de autor.
            DropdownButtonFormField<int>(
              // initialValue: qual autor ja vem selecionado ao abrir o form.
              // Em modo edicao, e o autor atual do livro; em criacao, e null.
              initialValue: autorIdSelecionado,
              decoration: const InputDecoration(labelText: 'Autor'),
              // Monta uma opcao para cada autor da lista.
              items: autores.map((autor) {
                return DropdownMenuItem<int>(
                  value: autor.id,
                  child: Text(autor.nome),
                );
              }).toList(),
              // Roda quando o usuario escolhe um autor no dropdown.
              onChanged: (novoValor) {
                setState(() {
                  autorIdSelecionado = novoValor;
                });
              },
              // Autor e obrigatorio: se nada foi escolhido, mostra erro.
              validator: (valor) {
                if (valor == null) {
                  return 'Selecione um autor';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botao Salvar: mostra loading e fica TRAVADO enquanto salva
            // (onPressed null = botao desabilitado). Isso impede envio duplicado.
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

            // Botao Cancelar: volta sem salvar.
            TextButton(
              onPressed: salvando ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

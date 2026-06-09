// Arquivo: lib/screens/formulario_page.dart
// O que faz: formulario UNICO que serve para CRIAR e tambem para EDITAR um livro.
// Quando e usado: ao tocar no "+" na lista (modo criacao) ou no lapis na tela
// de detalhe (modo edicao).

import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../services/livro_service.dart';

class FormularioPage extends StatefulWidget {
  // Parametro OPCIONAL:
  // - se vier null      -> modo CRIACAO
  // - se vier um livro  -> modo EDICAO
  final Livro? livro;

  const FormularioPage({super.key, this.livro});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final LivroService servico = LivroService();

  // GlobalKey<FormState>: e o "controle remoto" do Form.
  // Usamos para mandar o formulario validar todos os campos de uma vez.
  final GlobalKey<FormState> chaveFormulario = GlobalKey<FormState>();

  // TextEditingController: controla o texto de cada campo.
  // Com ele conseguimos LER o que o usuario digitou e tambem PRE-PREENCHER o campo.
  final TextEditingController controllerTitulo = TextEditingController();
  final TextEditingController controllerAno = TextEditingController();
  final TextEditingController controllerAutorId = TextEditingController();

  // Trava o botao Salvar enquanto a requisicao esta em andamento.
  bool salvando = false;

  // Diz se estamos editando (true) ou criando (false).
  bool get modoEdicao => widget.livro != null;

  @override
  void initState() {
    super.initState();
    // Se for edicao, preenchemos os campos com os valores do livro recebido.
    if (modoEdicao) {
      controllerTitulo.text = widget.livro!.titulo;
      controllerAno.text = widget.livro!.ano.toString();
      controllerAutorId.text = widget.livro!.autorId.toString();
    }
  }

  @override
  void dispose() {
    // dispose libera os controllers da memoria quando a tela e fechada.
    // Se esquecermos disso, o app fica vazando memoria (memory leak).
    controllerTitulo.dispose();
    controllerAno.dispose();
    controllerAutorId.dispose();
    super.dispose();
  }

  // Valida o formulario e envia para a API (POST se criar, PUT se editar).
  Future<void> salvar() async {
    // validate() roda os validators de cada TextFormField.
    // Se algum campo estiver invalido, paramos aqui (return).
    if (!chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true; // trava o botao para evitar envio duplicado
    });

    // Monta o objeto Livro com o que foi digitado.
    // No modo criacao o id ainda nao existe, entao usamos 0 (a API gera o id real).
    final livroDigitado = Livro(
      id: modoEdicao ? widget.livro!.id : 0,
      titulo: controllerTitulo.text,
      ano: int.parse(controllerAno.text),
      autorId: int.parse(controllerAutorId.text),
    );

    try {
      if (modoEdicao) {
        await servico.atualizar(livroDigitado);
      } else {
        await servico.criar(livroDigitado);
      }

      // mounted confirma que a tela ainda existe antes de usar o context.
      if (!mounted) return;
      mostrarMensagem('Livro salvo com sucesso!', Colors.green);

      // Volta para a tela anterior enviando "true" (deu certo, recarregue).
      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        salvando = false; // libera o botao de novo
      });
      mostrarMensagem('Erro ao salvar: $erro', Colors.red);
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
        // O titulo muda conforme o modo (criar ou editar).
        title: Text(modoEdicao ? 'Editar Livro' : 'Novo Livro'),
      ),
      body: Padding(
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
                  return null; // null = campo valido
                },
              ),
              const SizedBox(height: 12),

              // Campo Ano (obrigatorio, precisa ser numero).
              TextFormField(
                controller: controllerAno,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o ano';
                  }
                  if (int.tryParse(valor) == null) {
                    return 'Ano deve ser um numero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Campo Autor ID (obrigatorio, precisa ser numero).
              TextFormField(
                controller: controllerAutorId,
                decoration: const InputDecoration(labelText: 'Autor ID'),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o Autor ID';
                  }
                  if (int.tryParse(valor) == null) {
                    return 'Autor ID deve ser um numero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botao Salvar: mostra loading e fica TRAVADO enquanto salva
              // (onPressed null = botao desabilitado).
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
      ),
    );
  }
}

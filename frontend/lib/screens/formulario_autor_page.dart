// Arquivo: lib/screens/formulario_autor_page.dart
// O que faz: formulario UNICO que serve para CRIAR e tambem para EDITAR um autor.
// Quando e usado: ao tocar no "+" na lista de autores (modo criacao) ou no lapis
// na tela de detalhe do autor (modo edicao).

import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../services/autor_service.dart';

class FormularioAutorPage extends StatefulWidget {
  // Parametro OPCIONAL:
  // - se vier null      -> modo CRIACAO
  // - se vier um autor  -> modo EDICAO
  final Autor? autor;

  const FormularioAutorPage({super.key, this.autor});

  @override
  State<FormularioAutorPage> createState() => _FormularioAutorPageState();
}

class _FormularioAutorPageState extends State<FormularioAutorPage> {
  final AutorService servico = AutorService();

  // GlobalKey<FormState>: e o "controle remoto" do Form.
  // Usamos para mandar o formulario validar todos os campos de uma vez.
  final GlobalKey<FormState> chaveFormulario = GlobalKey<FormState>();

  // TextEditingController: controla o texto de cada campo.
  // Com ele conseguimos LER o que o usuario digitou e tambem PRE-PREENCHER o campo.
  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerNacionalidade = TextEditingController();

  // Trava o botao Salvar enquanto a requisicao esta em andamento.
  bool salvando = false;

  // Diz se estamos editando (true) ou criando (false).
  bool get modoEdicao => widget.autor != null;

  @override
  void initState() {
    super.initState();
    // Se for edicao, preenchemos os campos com os valores do autor recebido.
    if (modoEdicao) {
      controllerNome.text = widget.autor!.nome;
      controllerNacionalidade.text = widget.autor!.nacionalidade;
    }
  }

  @override
  void dispose() {
    // dispose libera os controllers da memoria quando a tela e fechada.
    // Se esquecermos disso, o app fica vazando memoria (memory leak).
    controllerNome.dispose();
    controllerNacionalidade.dispose();
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

    // Monta o objeto Autor com o que foi digitado.
    // No modo criacao o id ainda nao existe, entao usamos 0 (a API gera o id real).
    final autorDigitado = Autor(
      id: modoEdicao ? widget.autor!.id : 0,
      nome: controllerNome.text.trim(),
      nacionalidade: controllerNacionalidade.text.trim(),
    );

    try {
      if (modoEdicao) {
        await servico.atualizar(autorDigitado);
      } else {
        await servico.criar(autorDigitado);
      }

      // mounted confirma que a tela ainda existe antes de usar o context.
      if (!mounted) return;
      mostrarMensagem(
        modoEdicao ? 'Atualizado com sucesso' : 'Criado com sucesso',
        Colors.green,
      );

      // Volta para a tela anterior enviando "true" (deu certo, recarregue).
      Navigator.pop(context, true);
    } catch (erro) {
      setState(() {
        salvando = false; // libera o botao de novo
      });
      // erro.toString() traz a mensagem amigavel que a API mandou.
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
        // O titulo muda conforme o modo (criar ou editar).
        title: Text(modoEdicao ? 'Editar Autor' : 'Novo Autor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: chaveFormulario,
          child: ListView(
            children: [
              // Campo Nome (obrigatorio).
              TextFormField(
                controller: controllerNome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null; // null = campo valido
                },
              ),
              const SizedBox(height: 12),

              // Campo Nacionalidade (obrigatorio).
              TextFormField(
                controller: controllerNacionalidade,
                decoration: const InputDecoration(labelText: 'Nacionalidade'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe a nacionalidade';
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
      ),
    );
  }
}

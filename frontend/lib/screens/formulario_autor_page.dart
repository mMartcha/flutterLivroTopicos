import 'package:flutter/material.dart';

import '../models/autor.dart';
import '../services/autor_service.dart';
import '../theme/app_theme.dart';

class FormularioAutorPage extends StatefulWidget {
  final Autor? autor;

  const FormularioAutorPage({super.key, this.autor});

  @override
  State<FormularioAutorPage> createState() => _FormularioAutorPageState();
}

class _FormularioAutorPageState extends State<FormularioAutorPage> {
  final AutorService servico = AutorService();

  final GlobalKey<FormState> chaveFormulario = GlobalKey<FormState>();

  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerNacionalidade = TextEditingController();

  bool salvando = false;

  bool get modoEdicao => widget.autor != null;

  @override
  void initState() {
    super.initState();
    if (modoEdicao) {
      controllerNome.text = widget.autor!.nome;
      controllerNacionalidade.text = widget.autor!.nacionalidade;
    }
  }

  @override
  void dispose() {
    controllerNome.dispose();
    controllerNacionalidade.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!chaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

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
        title: Text(modoEdicao ? 'Editar Autor' : 'Novo Autor'),
      ),
      body: Padding(
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
                  'Dados do autor',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controllerNome,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllerNacionalidade,
                  decoration: const InputDecoration(
                    labelText: 'Nacionalidade',
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe a nacionalidade';
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
      ),
    );
  }
}

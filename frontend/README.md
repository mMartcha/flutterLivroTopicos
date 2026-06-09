# Biblioteca — Frontend (Flutter)

App Flutter simples que consome a API REST de **Biblioteca** (backend em Dart/Shelf).
Permite gerenciar **Autores** e **Livros** (CRUD completo) com o relacionamento
1:N entre eles (um autor tem vários livros; cada livro pertence a um autor).

---

## Pré-requisitos

- **Flutter SDK 3.41+** (este projeto foi feito na 3.41.8) e o **Dart** que vem junto.
- Um destino para rodar: **emulador Android**, navegador **Chrome** ou **Desktop**.
- O **backend rodando** (veja abaixo) — sem ele, o app abre mas não carrega dados.

Confira sua instalação com:

```bash
flutter --version
flutter doctor
```

---

## ⚠️ Importante: o backend precisa estar rodando ANTES

Este app é só a "cara" (frontend). Os dados ficam no backend. **Suba o backend primeiro.**

```bash
cd ../backend
dart pub get
dart run bin/server.dart
```

Quando aparecer `Servidor rodando em http://0.0.0.0:8080`, deixe esse terminal aberto.
Detalhes em [../backend/README.md](../backend/README.md).

---

## Como rodar o app

Em **outro terminal** (sem fechar o do backend):

```bash
cd frontend
flutter pub get
flutter run
```

Escolha o dispositivo quando o Flutter perguntar, ou force um:

```bash
flutter run -d emulator-5554   # emulador Android
flutter run -d chrome          # navegador
flutter run -d windows         # desktop Windows
```

---

## 🌐 URL da API: `10.0.2.2` vs `localhost`

A URL base da API é uma **constante no topo** de cada service
(`lib/services/autor_service.dart` e `lib/services/livro_service.dart`):

```dart
static const String _urlBase = 'http://10.0.2.2:8080';
```

| Onde você roda o app        | URL que funciona            |
| --------------------------- | --------------------------- |
| **Emulador Android**        | `http://10.0.2.2:8080`      |
| Chrome / Desktop / iOS sim. | `http://localhost:8080`     |

> Dentro do emulador Android, `localhost` é o *próprio celular virtual*, não o seu PC.
> O endereço `10.0.2.2` é um "apelido" que o emulador usa para o `localhost` do PC.
> **Se trocar de ambiente, troque a constante nos DOIS services.**

---

## Telas do app

| Tela                       | O que faz (1 linha)                                                        |
| -------------------------- | ------------------------------------------------------------------------- |
| `HomePage`                 | Tela inicial com dois botões grandes: **Autores** e **Livros**.           |
| `ListaAutoresPage`         | Lista todos os autores; "+" cria um novo; tocar abre o detalhe.           |
| `DetalheAutorPage`         | Mostra o autor, a seção "Livros deste autor", e botões editar/excluir.    |
| `FormularioAutorPage`      | Cria (POST) ou edita (PUT) um autor; mesma tela para os dois modos.       |
| `ListaLivrosPage`          | Lista os livros mostrando o **nome do autor**; "+" cria; tocar abre.      |
| `DetalheLivroPage`         | Mostra o livro (com nome do autor) e botões editar/excluir.               |
| `FormularioLivroPage`      | Cria/edita um livro; o autor é escolhido num **dropdown** de autores.     |

---

## Estrutura das pastas (`lib/`)

```
lib/
  main.dart                      # configura o app e abre na HomePage
  models/
    autor.dart                   # classe Autor (fromJson / toJson)
    livro.dart                   # classe Livro (fromJson / toJson)
  services/
    api_exception.dart           # classe de erro + leitura da mensagem da API
    autor_service.dart           # chamadas HTTP de autores
    livro_service.dart           # chamadas HTTP de livros
  screens/
    home_page.dart
    lista_autores_page.dart
    detalhe_autor_page.dart
    formulario_autor_page.dart
    lista_livros_page.dart
    detalhe_livro_page.dart
    formulario_livro_page.dart
```

---

## Decisões técnicas

- **HTTP:** pacote `http` puro (única dependência externa).
- **Estado:** `StatefulWidget` + `setState` (sem Provider/Bloc/Riverpod).
- **Navegação:** `Navigator.push` / `Navigator.pop` com `MaterialPageRoute`.
- **Validação:** `Form` + `TextFormField` + `GlobalKey<FormState>`.
- **Feedback:** `SnackBar` (sucesso/erro), `CircularProgressIndicator` (loading),
  `AlertDialog` (confirmação de exclusão).

# API de Biblioteca (Dart + Shelf + SQLite)

API REST simples para gerenciar **Autores** e **Livros**, feita com Dart usando
os pacotes `shelf` e `shelf_router`. O banco de dados é SQLite (arquivo
`biblioteca.db`, criado automaticamente na primeira execução).

---

## Como instalar as dependências

Você precisa ter o **Dart SDK** instalado (versão 3.0 ou superior).

Dentro da pasta `backend`, rode:

```bash
dart pub get
```

Esse comando lê o arquivo `pubspec.yaml` e baixa os pacotes usados
(`shelf`, `shelf_router`, `sqlite3`).

## Como rodar o servidor

```bash
dart run bin/server.dart
```

Ao iniciar, aparece no console:

```
Servidor rodando em http://0.0.0.0:8080
```

A API sobe na **porta 8080**. Para acessar do seu computador, use
`http://localhost:8080`.

---

## Entidades

### Autor
| Campo | Tipo   | Obrigatório |
|-------|--------|-------------|
| id    | int    | gerado automaticamente |
| nome  | String | sim |

### Livro
| Campo   | Tipo   | Obrigatório |
|---------|--------|-------------|
| id      | int    | gerado automaticamente |
| titulo  | String | sim |
| ano     | int    | sim |
| autorId | int    | sim (precisa ser um autor existente) |

---

## Padrão de respostas

- Sucesso: o corpo é o objeto ou a lista em JSON.
- Erro: o corpo é sempre `{ "error": "mensagem em português" }`.
- Todas as respostas usam `Content-Type: application/json; charset=utf-8`.

| Status | Quando acontece |
|--------|-----------------|
| 200 | OK (listagem, busca, atualização) |
| 201 | Criado com sucesso (POST) |
| 204 | Removido com sucesso (DELETE, sem corpo) |
| 400 | Body inválido ou campo obrigatório faltando |
| 404 | Registro não encontrado |
| 409 | Conflito: tentativa de excluir um autor que ainda possui livros |
| 422 | Regra de negócio violada: o `autorId` informado no livro não existe |
| 500 | Erro interno inesperado |

---

## Exemplos com `curl`

> Observação para Windows/PowerShell: troque as aspas simples `'` por aspas
> duplas `"` e escape as aspas internas, ou use o `curl.exe`. Os exemplos
> abaixo estão no formato padrão (bash/git bash).

### Autores

**1. Listar todos (GET → 200)**
```bash
curl http://localhost:8080/autores
```

**2. Buscar por id (GET → 200 ou 404)**
```bash
curl http://localhost:8080/autores/1
```

**3. Criar (POST → 201 ou 400)**
```bash
curl -X POST http://localhost:8080/autores \
  -H "Content-Type: application/json" \
  -d '{"nome": "Machado de Assis"}'
```

**4. Atualizar (PUT → 200 ou 404)**
```bash
curl -X PUT http://localhost:8080/autores/1 \
  -H "Content-Type: application/json" \
  -d '{"nome": "Joaquim Maria Machado de Assis"}'
```

**5. Remover (DELETE → 204, 404 ou 409)**
```bash
curl -X DELETE http://localhost:8080/autores/1
```
> Se o autor ainda tiver livros cadastrados, a API responde **409** com:
> `{ "error": "Não é possível excluir um autor que possui livros cadastrados." }`

**6. Listar os livros de um autor (GET → 200 ou 404)**
```bash
curl http://localhost:8080/autores/1/livros
```

### Livros

**1. Listar todos (GET → 200)**
```bash
curl http://localhost:8080/livros
```

**2. Buscar por id (GET → 200 ou 404)**
```bash
curl http://localhost:8080/livros/1
```

**3. Criar (POST → 201, 400 ou 422)**
```bash
curl -X POST http://localhost:8080/livros \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Dom Casmurro", "ano": 1899, "autorId": 1}'
```
> Se o `autorId` não existir, a API responde **422** com:
> `{ "error": "O autor informado não existe." }`

**4. Atualizar (PUT → 200, 404 ou 422)**
```bash
curl -X PUT http://localhost:8080/livros/1 \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Dom Casmurro (edição revisada)", "ano": 1900, "autorId": 1}'
```

**5. Remover (DELETE → 204 ou 404)**
```bash
curl -X DELETE http://localhost:8080/livros/1
```

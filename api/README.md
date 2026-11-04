# Todo API

API simples para o app Flutter.

## Endpoints

### `POST /auth/login`

Entra com e-mail e senha:

```json
{ "email": "aluno@todo.dev", "password": "123456" }
```

Responde `200` com o token e o usuário:

```json
{ "token": "3f1c2a9e-...", "user": { "id": 1, "name": "Aluno", "email": "aluno@todo.dev" } }
```

`400` quando falta e-mail ou senha, `401` quando estão errados. Contas de teste:

| Nome        | E-mail               | Senha      |
| ----------- | -------------------- | ---------- |
| Aluno       | `aluno@todo.dev`     | `123456`   |
| Professor   | `professor@todo.dev` | `senha123` |
| Maria Souza | `maria@todo.dev`     | `maria123` |
| João Lima   | `joao@todo.dev`      | `joao123`  |
| Ana Costa   | `ana@todo.dev`       | `ana123`   |

### `GET /todos`

Retorna a lista de tarefas:

```json
[
  { "id": 1, "title": "Estudar Clean Dart", "completed": false }
]
```

### `PATCH /todos/:id`

Atualiza o status da tarefa:

```json
{ "completed": true }
```

A resposta retorna a tarefa atualizada.

## Rodar localmente

```bash
cd api
npm install
npm start
```

A API fica disponível em `http://localhost:3000`.

## Railway

Crie um novo serviço no Railway apontando para este repositório e configure o **Root Directory** como `/api`. O Railway executará `npm start` e fornecerá a variável `PORT` automaticamente.

Depois de publicar, configure a URL pública no app Flutter, substituindo a `baseUrl` em `lib/main.dart`:

```dart
Dio(BaseOptions(baseUrl: 'https://SEU-SERVICO.up.railway.app'))
```

O armazenamento atual é em memória. Os dados retornam ao estado inicial quando o serviço reinicia ou é redeployado.

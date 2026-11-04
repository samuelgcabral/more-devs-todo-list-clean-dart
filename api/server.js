const crypto = require('node:crypto');
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const openapiDocument = {
    openapi: '3.0.3',
    info: {
        title: 'Todo Gabarito API',
        version: '1.0.0',
        description: 'API para login e para listar e atualizar tarefas, hábitos e notas.',
    },
    servers: [{ url: '/' }],
    paths: {
        '/auth/login': {
            post: {
                summary: 'Entra com e-mail e senha',
                description: 'Conta de teste: aluno@todo.dev / 123456',
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: { $ref: '#/components/schemas/LoginInput' },
                        },
                    },
                },
                responses: {
                    200: {
                        description: 'Login feito',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Session' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    401: { description: 'E-mail ou senha incorretos' },
                },
            },
        },
        '/': {
            get: {
                summary: 'Verifica o status da API',
                responses: {
                    200: {
                        description: 'API online',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Status' },
                            },
                        },
                    },
                },
            },
        },
        '/todos': {
            get: {
                summary: 'Lista as tarefas',
                responses: {
                    200: {
                        description: 'Lista de tarefas',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'array',
                                    items: { $ref: '#/components/schemas/Todo' },
                                },
                            },
                        },
                    },
                },
            },
        },
        '/todos/{id}': {
            patch: {
                summary: 'Atualiza o status de uma tarefa',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: {
                                type: 'object',
                                required: ['completed'],
                                properties: { completed: { type: 'boolean', example: true } },
                            },
                        },
                    },
                },
                responses: {
                    200: {
                        description: 'Tarefa atualizada',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Todo' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Tarefa não encontrada' },
                },
            },
        },
        '/habits': {
            get: {
                summary: 'Lista os hábitos com o histórico de check-ins',
                responses: {
                    200: {
                        description: 'Lista de hábitos',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'array',
                                    items: { $ref: '#/components/schemas/Habit' },
                                },
                            },
                        },
                    },
                },
            },
        },
        '/habits/{id}/checkins': {
            post: {
                summary: 'Registra o check-in de hoje (fuso de Brasília)',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                responses: {
                    201: {
                        description: 'Check-in registrado',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Habit' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Hábito não encontrado' },
                    409: { description: 'Check-in de hoje já registrado' },
                },
            },
        },
        '/notes': {
            get: {
                summary: 'Lista as notas (mais recentes primeiro)',
                responses: {
                    200: {
                        description: 'Lista de notas',
                        content: {
                            'application/json': {
                                schema: {
                                    type: 'array',
                                    items: { $ref: '#/components/schemas/Note' },
                                },
                            },
                        },
                    },
                },
            },
            post: {
                summary: 'Cria uma nota',
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: { $ref: '#/components/schemas/NoteInput' },
                        },
                    },
                },
                responses: {
                    201: {
                        description: 'Nota criada',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Note' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    409: { description: 'Limite de notas atingido' },
                },
            },
        },
        '/notes/{id}': {
            put: {
                summary: 'Atualiza o título e o texto de uma nota',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                requestBody: {
                    required: true,
                    content: {
                        'application/json': {
                            schema: { $ref: '#/components/schemas/NoteInput' },
                        },
                    },
                },
                responses: {
                    200: {
                        description: 'Nota atualizada',
                        content: {
                            'application/json': {
                                schema: { $ref: '#/components/schemas/Note' },
                            },
                        },
                    },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Nota não encontrada' },
                },
            },
            delete: {
                summary: 'Exclui uma nota',
                parameters: [{
                    name: 'id',
                    in: 'path',
                    required: true,
                    schema: { type: 'integer', example: 1 },
                }],
                responses: {
                    204: { description: 'Nota excluída' },
                    400: { description: 'Dados inválidos' },
                    404: { description: 'Nota não encontrada' },
                },
            },
        },
    },
    components: {
        schemas: {
            LoginInput: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                    email: { type: 'string', format: 'email', example: 'aluno@todo.dev' },
                    password: { type: 'string', example: '123456' },
                },
            },
            User: {
                type: 'object',
                required: ['id', 'name', 'email'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    name: { type: 'string', example: 'Aluno' },
                    email: { type: 'string', format: 'email', example: 'aluno@todo.dev' },
                },
            },
            Session: {
                type: 'object',
                required: ['token', 'user'],
                properties: {
                    token: { type: 'string', example: '3f1c2a9e-7b4d-4e8a-9c1f-2d6b8a0e5f3c' },
                    user: { $ref: '#/components/schemas/User' },
                },
            },
            Todo: {
                type: 'object',
                required: ['id', 'title', 'completed'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    title: { type: 'string', example: 'Estudar Clean Dart' },
                    completed: { type: 'boolean', example: false },
                },
            },
            Habit: {
                type: 'object',
                required: ['id', 'name', 'checkins'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    name: { type: 'string', example: 'Beber 2L de água' },
                    checkins: {
                        type: 'array',
                        description: 'Datas (AAAA-MM-DD) em ordem crescente',
                        items: { type: 'string', format: 'date', example: '2026-10-27' },
                    },
                },
            },
            Note: {
                type: 'object',
                required: ['id', 'title', 'content', 'updatedAt'],
                properties: {
                    id: { type: 'integer', example: 1 },
                    title: { type: 'string', example: 'O que é MVC' },
                    content: { type: 'string', example: 'Model, View e Controller.' },
                    updatedAt: {
                        type: 'string',
                        format: 'date-time',
                        example: '2026-10-29T13:45:00.000Z',
                    },
                },
            },
            NoteInput: {
                type: 'object',
                required: ['title'],
                properties: {
                    title: { type: 'string', maxLength: 100, example: 'O que é MVC' },
                    content: { type: 'string', maxLength: 2000, example: 'Model, View e Controller.' },
                },
            },
            Status: {
                type: 'object',
                properties: {
                    name: { type: 'string', example: 'todo-gabarito-api' },
                    status: { type: 'string', example: 'ok' },
                },
            },
        },
    },
};

app.get('/openapi.json', (_request, response) => response.json(openapiDocument));
app.use('/docs', swaggerUi.serve, swaggerUi.setup(openapiDocument));

let todos = [
    { id: 1, title: 'Estudar Clean Dart', completed: false },
    { id: 2, title: 'Fazer o exercício da aula', completed: false },
    { id: 3, title: 'Rever o diagrama de camadas', completed: true },
    { id: 4, title: 'Publicar a API no Railway', completed: false },
];

// Data de hoje (AAAA-MM-DD) no fuso de Brasília, para bater com o app.
const today = () =>
    new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Sao_Paulo' }).format(new Date());

const daysAgo = (days) => {
    const date = new Date(`${today()}T00:00:00Z`);
    date.setUTCDate(date.getUTCDate() - days);
    return date.toISOString().slice(0, 10);
};

const seedCheckins = (...days) => days.sort((a, b) => b - a).map(daysAgo);

let habits = [
    { id: 1, name: 'Beber 2L de água', checkins: seedCheckins(1, 2, 3, 4, 5) },
    { id: 2, name: 'Ler 10 páginas', checkins: seedCheckins(0, 1, 2) },
    { id: 3, name: 'Estudar Flutter', checkins: seedCheckins(1, 2, 4, 5, 6) },
    { id: 4, name: 'Caminhar 20 minutos', checkins: [] },
    { id: 5, name: 'Meditar', checkins: seedCheckins(3, 4) },
];

const moreHabitNames = [
    'Fazer 30 flexões', 'Dormir antes das 23h', 'Acordar às 6h', 'Arrumar a cama',
    'Tomar café da manhã', 'Comer uma fruta', 'Comer salada no almoço', 'Evitar refrigerante',
    'Evitar doces', 'Tomar vitaminas', 'Alongar 10 minutos', 'Correr 5 km',
    'Pedalar 30 minutos', 'Fazer yoga', 'Ir à academia', 'Subir de escada',
    'Dar 10 mil passos', 'Fazer prancha por 1 minuto', 'Praticar respiração', 'Escrever no diário',
    'Anotar 3 gratidões', 'Planejar o dia', 'Revisar a semana', 'Organizar a mesa',
    'Zerar a caixa de entrada', 'Lavar a louça', 'Regar as plantas', 'Passear com o cachorro',
    'Ligar para a família', 'Mandar mensagem para um amigo', 'Elogiar alguém', 'Estudar inglês',
    'Praticar espanhol', 'Fazer uma lição no Duolingo', 'Ler um artigo técnico', 'Resolver um exercício de lógica',
    'Fazer um commit', 'Revisar anotações da aula', 'Assistir a uma aula online', 'Ouvir um podcast',
    'Ler notícias', 'Praticar violão', 'Desenhar 15 minutos', 'Tirar uma foto',
    'Escrever um poema', 'Cozinhar em casa', 'Levar marmita', 'Economizar R$ 10',
    'Anotar os gastos', 'Não comprar por impulso', 'Ficar 1 hora sem celular', 'Sem redes sociais antes das 10h',
    'Desligar telas às 22h', 'Tomar sol por 15 minutos', 'Passar protetor solar', 'Usar fio dental',
    'Fazer skincare à noite', 'Beber chá', 'Reduzir o café', 'Fazer um lanche saudável',
    'Pausar a cada hora', 'Corrigir a postura', 'Fazer 20 agachamentos', 'Pular corda',
    'Nadar', 'Jogar xadrez', 'Fazer palavras cruzadas', 'Aprender uma palavra nova',
    'Ler um conto', 'Estudar Dart', 'Praticar digitação', 'Separar o lixo reciclável',
    'Usar garrafa reutilizável', 'Ir a pé ao trabalho', 'Ajudar alguém', 'Visualizar as metas',
    'Arrumar a mochila', 'Separar a roupa de amanhã', 'Ficar 5 minutos em silêncio', 'Agradecer alguém',
];

// Gerador aleatório com semente: os check-ins variam entre os hábitos,
// mas são sempre os mesmos a cada vez que a API sobe.
const seededRandom = (seed) => () => {
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const randomDays = (seed) => {
    const random = seededRandom(seed);
    const frequency = random();
    return Array.from({ length: 21 }, (_, day) => day).filter(() => random() < frequency);
};

habits.push(
    ...moreHabitNames.map((name, index) => {
        const id = habits.length + index + 1;
        return { id, name, checkins: seedCheckins(...randomDays(id)) };
    }),
);

app.get('/', (_request, response) => {
    response.json({ name: 'todo-gabarito-api', status: 'ok' });
});

// Usuários de exemplo. Uma API de verdade guardaria só o hash da senha.
const users = [
    { id: 1, name: 'Aluno', email: 'aluno@todo.dev', password: '123456' },
    { id: 2, name: 'Professor', email: 'professor@todo.dev', password: 'senha123' },
    { id: 3, name: 'Maria Souza', email: 'maria@todo.dev', password: 'maria123' },
    { id: 4, name: 'João Lima', email: 'joao@todo.dev', password: 'joao123' },
    { id: 5, name: 'Ana Costa', email: 'ana@todo.dev', password: 'ana123' },
];

app.post('/auth/login', (request, response) => {
    const { email, password } = request.body ?? {};

    if (typeof email !== 'string' || !email.trim() || typeof password !== 'string' || !password) {
        return response.status(400).json({ error: 'Informe o e-mail e a senha.' });
    }

    const user = users.find(
        (item) => item.email === email.trim().toLowerCase() && item.password === password,
    );
    // Mesma resposta para e-mail inexistente e senha errada: não revela quem tem conta.
    if (!user) {
        return response.status(401).json({ error: 'E-mail ou senha incorretos.' });
    }

    return response.json({
        token: crypto.randomUUID(),
        user: { id: user.id, name: user.name, email: user.email },
    });
});

app.get('/todos', (_request, response) => {
    response.json(todos);
});

app.patch('/todos/:id', (request, response) => {
    const id = Number(request.params.id);
    const { completed } = request.body;

    if (!Number.isInteger(id)) {
        return response.status(400).json({ error: 'O id deve ser um número inteiro.' });
    }

    if (typeof completed !== 'boolean') {
        return response
            .status(400)
            .json({ error: 'O campo completed deve ser booleano.' });
    }

    const todo = todos.find((item) => item.id === id);
    if (!todo) {
        return response.status(404).json({ error: 'Tarefa não encontrada.' });
    }

    todo.completed = completed;
    return response.json(todo);
});

app.get('/habits', (_request, response) => {
    response.json(habits);
});

app.post('/habits/:id/checkins', (request, response) => {
    const id = Number(request.params.id);

    if (!Number.isInteger(id)) {
        return response.status(400).json({ error: 'O id deve ser um número inteiro.' });
    }

    const habit = habits.find((item) => item.id === id);
    if (!habit) {
        return response.status(404).json({ error: 'Hábito não encontrado.' });
    }

    const date = today();
    if (habit.checkins.includes(date)) {
        return response.status(409).json({ error: 'Check-in de hoje já registrado.' });
    }

    habit.checkins.push(date);
    return response.status(201).json(habit);
});

const hoursAgo = (hours) => new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();

let notes = [
    {
        id: 1,
        title: 'Camadas do Clean Dart',
        content: 'Domain, Infra, External e Presenter. O Domain não conhece ninguém.',
        updatedAt: hoursAgo(1),
    },
    {
        id: 2,
        title: 'O que é MVC',
        content: 'O Model guarda os dados e as regras, a View mostra a tela e o Controller liga os dois.',
        updatedAt: hoursAgo(5),
    },
    {
        id: 3,
        title: 'Comandos do Flutter',
        content: 'flutter pub get\nflutter test\nflutter run',
        updatedAt: hoursAgo(26),
    },
    {
        id: 4,
        title: 'Verbos HTTP',
        content: 'GET lê, POST cria, PUT substitui, PATCH altera uma parte e DELETE remove.',
        updatedAt: hoursAgo(50),
    },
    {
        id: 5,
        title: 'Ideias para o app',
        content: 'Modo escuro, busca nas notas e um lembrete diário dos hábitos.',
        updatedAt: hoursAgo(24 * 4),
    },
    {
        id: 6,
        title: 'Lista do mercado',
        content: 'Café, pão, ovos, banana e leite.',
        updatedAt: hoursAgo(24 * 9),
    },
];
let nextNoteId = notes.length + 1;
const maxNotes = 300;

// Valida o corpo do POST e do PUT. Devolve { error } ou { title, content }.
const readNoteInput = (body) => {
    const { title, content = '' } = body ?? {};

    if (typeof title !== 'string' || !title.trim()) {
        return { error: 'O campo title é obrigatório.' };
    }
    if (typeof content !== 'string') {
        return { error: 'O campo content deve ser texto.' };
    }
    if (title.trim().length > 100 || content.length > 2000) {
        return { error: 'Use até 100 caracteres no title e 2000 no content.' };
    }
    return { title: title.trim(), content };
};

// Acha a nota do :id ou já responde 400/404. Devolve undefined nesse caso.
const findNote = (request, response) => {
    const id = Number(request.params.id);

    if (!Number.isInteger(id)) {
        response.status(400).json({ error: 'O id deve ser um número inteiro.' });
        return undefined;
    }

    const note = notes.find((item) => item.id === id);
    if (!note) {
        response.status(404).json({ error: 'Nota não encontrada.' });
    }
    return note;
};

app.get('/notes', (_request, response) => {
    response.json([...notes].sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)));
});

app.post('/notes', (request, response) => {
    const input = readNoteInput(request.body);
    if (input.error) {
        return response.status(400).json({ error: input.error });
    }
    if (notes.length >= maxNotes) {
        return response.status(409).json({ error: 'Limite de notas atingido.' });
    }

    const note = { id: nextNoteId++, ...input, updatedAt: new Date().toISOString() };
    notes.push(note);
    return response.status(201).json(note);
});

app.put('/notes/:id', (request, response) => {
    const note = findNote(request, response);
    if (!note) return undefined;

    const input = readNoteInput(request.body);
    if (input.error) {
        return response.status(400).json({ error: input.error });
    }

    Object.assign(note, input, { updatedAt: new Date().toISOString() });
    return response.json(note);
});

app.delete('/notes/:id', (request, response) => {
    const note = findNote(request, response);
    if (!note) return undefined;

    notes = notes.filter((item) => item !== note);
    return response.status(204).end();
});

app.use((_request, response) => {
    response.status(404).json({ error: 'Rota não encontrada.' });
});

app.listen(port, () => {
    console.log(`Todo API running on port ${port}`);
});

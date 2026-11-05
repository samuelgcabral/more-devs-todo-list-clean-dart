import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_gabarito/modules/todos/domain/usecases/update_todos_use_case.dart';

import 'modules/auth/model/auth_service.dart';
import 'modules/auth/model/session_storage.dart';
import 'modules/auth/view/login_page.dart';
import 'modules/auth/viewmodel/login_view_model.dart';
import 'modules/habits/model/habits_service.dart';
import 'modules/habits/view/habits_page.dart';
import 'modules/habits/viewmodel/habits_view_model.dart';
import 'modules/notes/controller/notes_controller.dart';
import 'modules/notes/model/notes_service.dart';
import 'modules/notes/view/notes_page.dart';
import 'modules/shared/connectivity/connection_status.dart';
import 'modules/shared/connectivity/offline_banner.dart';
import 'modules/todos/domain/usecases/get_todos.dart';
import 'modules/todos/external/datasources/todo_api_datasource.dart';
import 'modules/todos/infra/datasources/todo_datasource.dart';
import 'modules/todos/infra/repositories/todo_repository_impl.dart';
import 'modules/todos/presenter/todos_controller.dart';
import 'modules/todos/presenter/todos_page.dart';

/// Único lugar que sabe quais implementações usar.
Future<void> main() async {
  // shared_preferences e connectivity_plus usam canais nativos, que precisam
  // disso antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final connection = ConnectionStatus(Connectivity());
  await connection.start();

  final dio = Dio(
    BaseOptions(baseUrl: 'https://todo-api-production-62d2.up.railway.app'),
  );

  // Clean Dart: datasource → repositório → casos de uso → controller.
  final TodoDatasource datasource = TodoApiDatasource(dio);
  final repository = TodoRepositoryImpl(datasource);
  final todosController = TodosController(
    updateUseCase: UpdateTodoUseCase(repository),
    getTodos: GetTodosUseCase(repository),
  )..load();

  // MVC: o controller fala direto com o Model.
  final notesController = NotesController(NotesService(dio))..load();

  // MVVM: a View observa o ViewModel, que fala com o Model.
  final habitsViewModel = HabitsViewModel(HabitsService(dio))..load();
  final loginViewModel = LoginViewModel(
    AuthService(dio),
    SessionStorage(prefs),
    connection,
  );

  // Toda requisição leva o token da sessão atual, seja a recém-criada no login
  // ou a restaurada do aparelho.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = loginViewModel.session?.token;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ));

  // Antes do runApp, para quem foi lembrado não ver o login piscar na tela.
  await loginViewModel.restoreSession();

  final home = HomeShell(
    onLogout: loginViewModel.logout,
    pages: [
      TodosPage(controller: todosController),
      HabitsPage(viewModel: habitsViewModel),
      NotesPage(controller: notesController),
    ],
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315CFF)),
    ),
    builder: (context, child) =>
        OfflineBanner(status: connection, child: child!),
    // Enquanto não houver sessão, mostra o login; depois, o app.
    home: ListenableBuilder(
      listenable: loginViewModel,
      builder: (context, _) =>
          loginViewModel.loggedIn ? home : LoginPage(viewModel: loginViewModel),
    ),
  ));
}

/// Navegação entre os módulos. Fica aqui para um módulo não importar o outro.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.pages, required this.onLogout});

  final List<Widget> pages;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: widget.pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          // O último item não é uma aba: é a ação de sair.
          if (value == widget.pages.length) {
            widget.onLogout();
          } else {
            setState(() => index = value);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_rounded),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_rounded),
            label: 'Notas',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout_rounded),
            label: 'Sair',
          ),
        ],
      ),
    );
  }
}

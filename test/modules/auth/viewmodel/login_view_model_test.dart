import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/auth/model/session.dart';
import 'package:todo_gabarito/modules/auth/viewmodel/login_view_model.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_connection_status.dart';
import '../../../helpers/fake_session_storage.dart';

void main() {
  test('só deixa enviar com e-mail e senha preenchidos', () {
    final viewModel = LoginViewModel(
        FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus());
    expect(viewModel.canSubmit, isFalse);

    viewModel.setEmail('aluno@todo.dev');
    expect(viewModel.canSubmit, isFalse);

    viewModel.setPassword('123456');
    expect(viewModel.canSubmit, isTrue);

    viewModel.setEmail('   ');
    expect(viewModel.canSubmit, isFalse);
  });

  test('login certo cria a sessão', () async {
    final viewModel = LoginViewModel(
        FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus())
      ..setEmail('  aluno@todo.dev ')
      ..setPassword('123456');

    await viewModel.login();

    expect(viewModel.loggedIn, isTrue);
    expect(viewModel.session!.user.name, 'Aluno');
    expect(viewModel.error, isNull);
    expect(viewModel.loading, isFalse);
  });

  test('e-mail inválido mostra erro no campo e não chama a API', () async {
    final service = FakeAuthService();
    final viewModel =
        LoginViewModel(service, FakeSessionStorage(), FakeConnectionStatus())
          ..setEmail('aluno')
          ..setPassword('123456');

    await viewModel.login();

    expect(viewModel.emailError, 'Digite um e-mail válido');
    expect(service.calls, isEmpty);
    expect(viewModel.loggedIn, isFalse);

    viewModel.setEmail('aluno@');
    expect(viewModel.emailError, isNull);
  });

  test('senha errada vira mensagem de credenciais incorretas', () async {
    final viewModel = LoginViewModel(
        FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus())
      ..setEmail('aluno@todo.dev')
      ..setPassword('errada');

    await viewModel.login();

    expect(viewModel.error, 'E-mail ou senha incorretos');
    expect(viewModel.loggedIn, isFalse);

    viewModel.setPassword('outra');
    expect(viewModel.error, isNull);
  });

  test('falha de rede vira mensagem genérica', () async {
    final viewModel = LoginViewModel(FakeAuthService()..fail = true,
        FakeSessionStorage(), FakeConnectionStatus())
      ..setEmail('aluno@todo.dev')
      ..setPassword('123456');

    await viewModel.login();

    expect(viewModel.error, 'Não foi possível entrar. Tente de novo.');
    expect(viewModel.loggedIn, isFalse);
  });

  test('enquanto carrega, não aceita um segundo envio', () async {
    final service = FakeAuthService()..gate = Completer();
    final viewModel =
        LoginViewModel(service, FakeSessionStorage(), FakeConnectionStatus())
          ..setEmail('aluno@todo.dev')
          ..setPassword('123456');

    final first = viewModel.login();
    expect(viewModel.loading, isTrue);
    expect(viewModel.canSubmit, isFalse);

    await viewModel.login();
    expect(service.calls, hasLength(1));

    service.gate!.complete();
    await first;
    expect(viewModel.loading, isFalse);
    expect(viewModel.loggedIn, isTrue);
  });

  test('alternar a visibilidade da senha', () {
    final viewModel = LoginViewModel(
        FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus());
    expect(viewModel.obscurePassword, isTrue);

    viewModel.togglePasswordVisibility();

    expect(viewModel.obscurePassword, isFalse);
  });

  test('"Lembrar de mim" começa desmarcado e alterna', () {
    final viewModel = LoginViewModel(
        FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus());
    expect(viewModel.rememberMe, isFalse);

    viewModel.toggleRememberMe();

    expect(viewModel.rememberMe, isTrue);
  });

  group('Lembrar de mim', () {
    const remembered = Session(
      token: 'token-guardado',
      user: User(id: 1, name: 'Aluno', email: 'aluno@todo.dev'),
    );

    LoginViewModel filledIn(FakeSessionStorage storage, {String? password}) =>
        LoginViewModel(FakeAuthService(), storage, FakeConnectionStatus())
          ..setEmail('aluno@todo.dev')
          ..setPassword(password ?? '123456');

    test('marcado, guarda a sessão ao entrar', () async {
      final storage = FakeSessionStorage();
      final viewModel = filledIn(storage)..toggleRememberMe();

      await viewModel.login();

      expect(storage.saved!.token, 'token-de-teste');
    });

    test('desmarcado, entra sem guardar nada', () async {
      final storage = FakeSessionStorage();
      final viewModel = filledIn(storage);

      await viewModel.login();

      expect(viewModel.loggedIn, isTrue);
      expect(storage.saved, isNull);
    });

    test('login recusado não guarda nada', () async {
      final storage = FakeSessionStorage();
      final viewModel = filledIn(storage, password: 'errada')
        ..toggleRememberMe();

      await viewModel.login();

      expect(storage.saved, isNull);
    });

    test('falha ao guardar não impede a entrada', () async {
      final viewModel = filledIn(FakeSessionStorage()..fail = true)
        ..toggleRememberMe();

      await viewModel.login();

      expect(viewModel.loggedIn, isTrue);
      expect(viewModel.error, isNull);
      expect(viewModel.loading, isFalse);
    });

    test('ao abrir, entra direto com a sessão guardada', () async {
      final viewModel = LoginViewModel(
        FakeAuthService(),
        FakeSessionStorage(saved: remembered),
        FakeConnectionStatus(),
      );
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.restoreSession();

      expect(viewModel.loggedIn, isTrue);
      expect(viewModel.session!.token, 'token-guardado');
      expect(notified, isTrue);
    });

    test('ao abrir sem sessão guardada, fica no login', () async {
      final viewModel = LoginViewModel(
          FakeAuthService(), FakeSessionStorage(), FakeConnectionStatus());

      await viewModel.restoreSession();

      expect(viewModel.loggedIn, isFalse);
    });

    test('ao abrir com sessão ilegível, fica no login sem erro', () async {
      final viewModel = LoginViewModel(
        FakeAuthService(),
        FakeSessionStorage(saved: remembered)..fail = true,
        FakeConnectionStatus(),
      );

      await viewModel.restoreSession();

      expect(viewModel.loggedIn, isFalse);
      expect(viewModel.error, isNull);
    });

    test('sair apaga a sessão guardada e limpa o formulário', () async {
      final storage = FakeSessionStorage();
      final viewModel = filledIn(storage)
        ..toggleRememberMe()
        ..togglePasswordVisibility();
      await viewModel.login();

      await viewModel.logout();

      expect(viewModel.loggedIn, isFalse);
      expect(storage.saved, isNull);
      expect(viewModel.canSubmit, isFalse);
      expect(viewModel.rememberMe, isFalse);
      expect(viewModel.obscurePassword, isTrue);
    });

    test('falha ao apagar não impede a saída', () async {
      final storage = FakeSessionStorage(saved: remembered);
      final viewModel =
          LoginViewModel(FakeAuthService(), storage, FakeConnectionStatus());
      await viewModel.restoreSession();
      storage.fail = true;

      await viewModel.logout();

      expect(viewModel.loggedIn, isFalse);
    });
  });

  group('Sem internet', () {
    test('não chama a API e avisa que está sem conexão', () async {
      final service = FakeAuthService();
      final viewModel = LoginViewModel(
        service,
        FakeSessionStorage(),
        FakeConnectionStatus(online: false),
      )
        ..setEmail('aluno@todo.dev')
        ..setPassword('123456');

      await viewModel.login();

      expect(service.calls, isEmpty);
      expect(viewModel.error, 'Sem conexão com a internet');
      expect(viewModel.loggedIn, isFalse);
      expect(viewModel.loading, isFalse);
    });

    test('quando a rede volta, o login funciona', () async {
      final connection = FakeConnectionStatus(online: false);
      final viewModel =
          LoginViewModel(FakeAuthService(), FakeSessionStorage(), connection)
            ..setEmail('aluno@todo.dev')
            ..setPassword('123456');
      await viewModel.login();

      connection.set(true);
      await viewModel.login();

      expect(viewModel.loggedIn, isTrue);
      expect(viewModel.error, isNull);
    });

    test('a sessão guardada entra mesmo offline', () async {
      final viewModel = LoginViewModel(
        FakeAuthService(),
        FakeSessionStorage(
          saved: const Session(
            token: 'token-guardado',
            user: User(id: 1, name: 'Aluno', email: 'aluno@todo.dev'),
          ),
        ),
        FakeConnectionStatus(online: false),
      );

      await viewModel.restoreSession();

      expect(viewModel.loggedIn, isTrue);
    });
  });
}

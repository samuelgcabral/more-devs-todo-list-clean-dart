import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/auth/view/login_page.dart';
import 'package:todo_gabarito/modules/auth/viewmodel/login_view_model.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_session_storage.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);
  Finder button() => find.widgetWithText(FilledButton, 'Entrar');

  testWidgets('o botão só habilita com os dois campos preenchidos',
      (tester) async {
    final viewModel = LoginViewModel(FakeAuthService(), FakeSessionStorage());
    await tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));

    expect(tester.widget<FilledButton>(button()).onPressed, isNull);

    await tester.enterText(field('E-mail'), 'aluno@todo.dev');
    await tester.enterText(field('Senha'), '123456');
    await tester.pump();

    expect(tester.widget<FilledButton>(button()).onPressed, isNotNull);
  });

  testWidgets('senha errada mostra o erro na tela', (tester) async {
    final viewModel = LoginViewModel(FakeAuthService(), FakeSessionStorage());
    await tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));

    await tester.enterText(field('E-mail'), 'aluno@todo.dev');
    await tester.enterText(field('Senha'), 'errada');
    await tester.pump();
    await tester.tap(button());
    await tester.pump();

    expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
    expect(viewModel.loggedIn, isFalse);
  });

  testWidgets('login certo pelo teclado cria a sessão', (tester) async {
    final viewModel = LoginViewModel(FakeAuthService(), FakeSessionStorage());
    await tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));

    await tester.enterText(field('E-mail'), 'aluno@todo.dev');
    await tester.enterText(field('Senha'), '123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(viewModel.loggedIn, isTrue);
  });

  testWidgets('o olho mostra e esconde a senha', (tester) async {
    final viewModel = LoginViewModel(FakeAuthService(), FakeSessionStorage());
    await tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));

    bool obscured() =>
        tester.widget<TextField>(field('Senha')).obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    expect(obscured(), isFalse);
  });

  testWidgets('marcar "Lembrar de mim" guarda a sessão ao entrar',
      (tester) async {
    final storage = FakeSessionStorage();
    final viewModel = LoginViewModel(FakeAuthService(), storage);
    await tester.pumpWidget(MaterialApp(home: LoginPage(viewModel: viewModel)));

    await tester.enterText(field('E-mail'), 'aluno@todo.dev');
    await tester.enterText(field('Senha'), '123456');
    await tester.tap(find.text('Lembrar de mim'));
    await tester.pump();
    await tester.tap(button());
    await tester.pump();

    expect(viewModel.loggedIn, isTrue);
    expect(storage.saved, isNotNull);
  });
}

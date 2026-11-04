import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/main.dart';

void main() {
  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  testWidgets('"Sair" chama o logout e não vira uma aba', (tester) async {
    var loggedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          onLogout: () => loggedOut = true,
          pages: const [Text('Tarefas'), Text('Hábitos'), Text('Notas')],
        ),
      ),
    );

    await tester.tap(find.text('Sair'));
    await tester.pump();

    expect(loggedOut, isTrue);
    expect(selectedTab(tester), 0);
  });

  testWidgets('as abas continuam trocando sem chamar o logout', (tester) async {
    var loggedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          onLogout: () => loggedOut = true,
          pages: const [Text('Tarefas'), Text('Hábitos'), Text('Notas')],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.sticky_note_2_rounded));
    await tester.pump();

    expect(selectedTab(tester), 2);
    expect(loggedOut, isFalse);
  });
}

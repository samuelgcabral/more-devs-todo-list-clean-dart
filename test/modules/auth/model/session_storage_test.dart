import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/auth/model/session.dart';
import 'package:todo_gabarito/modules/auth/model/session_storage.dart';

void main() {
  const session = Session(
    token: 'abc-123',
    user: User(id: 1, name: 'Aluno', email: 'aluno@todo.dev'),
  );

  Future<SessionStorage> storageWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SessionStorage(await SharedPreferences.getInstance());
  }

  test('sem nada guardado, não há sessão', () async {
    expect(await (await storageWith({})).read(), isNull);
  });

  test('o que foi guardado volta igual', () async {
    final storage = await storageWith({});

    await storage.save(session);
    final restored = await storage.read();

    expect(restored!.token, 'abc-123');
    expect(restored.user.id, 1);
    expect(restored.user.name, 'Aluno');
    expect(restored.user.email, 'aluno@todo.dev');
  });

  test('clear apaga a sessão guardada', () async {
    final storage = await storageWith({});
    await storage.save(session);

    await storage.clear();

    expect(await storage.read(), isNull);
  });

  test('conteúdo inválido lança erro em vez de virar sessão', () async {
    final storage = await storageWith({'session': 'não é json'});

    expect(storage.read(), throwsA(isA<FormatException>()));
  });
}

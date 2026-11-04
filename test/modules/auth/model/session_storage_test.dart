import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/auth/model/session.dart';
import 'package:todo_gabarito/modules/auth/model/session_storage.dart';

void main() {
  const session = Session(
    token: 'abc-123',
    user: User(id: 1, name: 'Aluno', email: 'aluno@todo.dev'),
  );

  SessionStorage storageWith(Map<String, String> values) {
    FlutterSecureStorage.setMockInitialValues(values);
    return SessionStorage(const FlutterSecureStorage());
  }

  test('sem nada guardado, não há sessão', () async {
    expect(await storageWith({}).read(), isNull);
  });

  test('o que foi guardado volta igual', () async {
    final storage = storageWith({});

    await storage.save(session);
    final restored = await storage.read();

    expect(restored!.token, 'abc-123');
    expect(restored.user.id, 1);
    expect(restored.user.name, 'Aluno');
    expect(restored.user.email, 'aluno@todo.dev');
  });

  test('clear apaga a sessão guardada', () async {
    final storage = storageWith({});
    await storage.save(session);

    await storage.clear();

    expect(await storage.read(), isNull);
  });

  test('conteúdo inválido lança erro em vez de virar sessão', () async {
    final storage = storageWith({'session': 'não é json'});

    expect(storage.read(), throwsA(isA<FormatException>()));
  });
}

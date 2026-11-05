import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_gabarito/modules/auth/model/session.dart';
import 'package:todo_gabarito/modules/auth/model/session_storage.dart';

/// Armazenamento falso: guarda a sessão em memória, nada de canal nativo.
class FakeSessionStorage extends SessionStorage {
  FakeSessionStorage({this.saved}) : super(_NoPrefs());

  Session? saved;
  bool fail = false;

  @override
  Future<void> save(Session session) async {
    if (fail) throw Exception('Falha simulada');
    saved = session;
  }

  @override
  Future<Session?> read() async {
    if (fail) throw Exception('Falha simulada');
    return saved;
  }

  @override
  Future<void> clear() async {
    if (fail) throw Exception('Falha simulada');
    saved = null;
  }
}

/// Nunca é usado: o fake sobrescreve tudo que tocaria nas preferências.
class _NoPrefs implements SharedPreferences {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

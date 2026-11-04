import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';

/// Guarda a sessão no armazenamento seguro do aparelho, para o "Lembrar de mim"
/// sobreviver ao fechamento do app. Só o token e o usuário: a senha nunca é salva.
class SessionStorage {
  SessionStorage(this.storage);

  static const _key = 'session';

  final FlutterSecureStorage storage;

  Future<void> save(Session session) =>
      storage.write(key: _key, value: jsonEncode(session.toMap()));

  Future<Session?> read() async {
    final saved = await storage.read(key: _key);
    if (saved == null) return null;
    return Session.fromMap(jsonDecode(saved) as Map<String, dynamic>);
  }

  Future<void> clear() => storage.delete(key: _key);
}

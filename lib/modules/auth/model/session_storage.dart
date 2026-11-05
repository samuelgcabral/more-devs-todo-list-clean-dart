import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session.dart';

/// Guarda a sessão no shared_preferences, para o login ser automático quando o
/// app abrir de novo. Só o token e o usuário: a senha nunca é salva.
class SessionStorage {
  SessionStorage(this.prefs);

  static const _key = 'session';

  final SharedPreferences prefs;

  Future<void> save(Session session) async {
    final saved = await prefs.setString(_key, jsonEncode(session.toMap()));
    if (!saved) throw Exception('O aparelho não guardou a sessão');
  }

  Future<Session?> read() async {
    final saved = prefs.getString(_key);
    if (saved == null) return null;
    return Session.fromMap(jsonDecode(saved) as Map<String, dynamic>);
  }

  Future<void> clear() => prefs.remove(_key);
}

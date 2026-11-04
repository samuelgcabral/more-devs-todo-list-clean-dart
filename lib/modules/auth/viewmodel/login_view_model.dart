import 'package:flutter/foundation.dart';

import '../model/auth_service.dart';
import '../model/session.dart';
import '../model/session_storage.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this.service, this.sessionStorage);

  final AuthService service;
  final SessionStorage sessionStorage;

  String _email = '';
  String _password = '';

  bool loading = false;
  bool obscurePassword = true;
  bool rememberMe = false;
  String? emailError;
  String? error;
  Session? session;

  bool get loggedIn => session != null;

  bool get canSubmit =>
      !loading && _email.trim().isNotEmpty && _password.isNotEmpty;

  void setEmail(String value) {
    _email = value;
    emailError = null;
    error = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  /// Abre o app já logado se houver sessão guardada. Se não der para ler o que
  /// foi guardado, o usuário só precisa entrar de novo.
  Future<void> restoreSession() async {
    try {
      session = await sessionStorage.read();
    } catch (e) {
      debugPrint('Não foi possível ler a sessão guardada: $e');
    }
    notifyListeners();
  }

  Future<void> login() async {
    if (!canSubmit) return;

    final email = _email.trim();
    if (!_emailPattern.hasMatch(email)) {
      emailError = 'Digite um e-mail válido';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();
    try {
      final newSession = await service.login(email, _password);
      if (rememberMe) await _remember(newSession);
      session = newSession;
    } on InvalidCredentialsException {
      error = 'E-mail ou senha incorretos';
    } catch (_) {
      error = 'Não foi possível entrar. Tente de novo.';
    }
    loading = false;
    notifyListeners();
  }

  /// O login já deu certo: se o aparelho não guardar, ele só não será lembrado.
  Future<void> _remember(Session session) async {
    try {
      await sessionStorage.save(session);
    } catch (e) {
      debugPrint('Não foi possível guardar a sessão: $e');
    }
  }

  /// Volta para o login com o formulário limpo: os campos da tela renascem
  /// vazios, então o e-mail e a senha daqui também precisam sumir.
  Future<void> logout() async {
    try {
      await sessionStorage.clear();
    } catch (e) {
      debugPrint('Não foi possível apagar a sessão guardada: $e');
    }
    session = null;
    _email = '';
    _password = '';
    rememberMe = false;
    obscurePassword = true;
    notifyListeners();
  }
}

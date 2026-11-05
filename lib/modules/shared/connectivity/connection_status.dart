import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Diz se o aparelho está conectado a alguma rede e avisa quando isso muda.
/// Fica em `shared` porque qualquer módulo pode precisar saber.
class ConnectionStatus extends ChangeNotifier {
  ConnectionStatus(this.connectivity);

  final Connectivity connectivity;

  /// Começa otimista: na dúvida, deixa a requisição tentar.
  bool online = true;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> start() async {
    _subscription ??= connectivity.onConnectivityChanged.listen(_update);
    try {
      _update(await connectivity.checkConnectivity());
    } catch (e) {
      debugPrint('Não foi possível checar a conexão: $e');
    }
  }

  void _update(List<ConnectivityResult> results) {
    final now = results.any((result) => result != ConnectivityResult.none);
    if (now == online) return;
    online = now;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

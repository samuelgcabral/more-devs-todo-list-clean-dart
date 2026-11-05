import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo_gabarito/modules/shared/connectivity/connection_status.dart';

/// Conexão falsa: online por padrão, nada de canal nativo.
class FakeConnectionStatus extends ConnectionStatus {
  FakeConnectionStatus({bool online = true}) : super(Connectivity()) {
    this.online = online;
  }

  @override
  Future<void> start() async {}

  void set(bool value) {
    online = value;
    notifyListeners();
  }
}

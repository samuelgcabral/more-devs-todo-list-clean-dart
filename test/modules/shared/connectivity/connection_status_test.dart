import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/shared/connectivity/connection_status.dart';

/// Connectivity falso: o teste decide o estado inicial e as mudanças.
class FakeConnectivity implements Connectivity {
  FakeConnectivity(this.initial);

  List<ConnectivityResult> initial;
  final changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => initial;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;
}

void main() {
  test('com wi-fi, está online', () async {
    final status =
        ConnectionStatus(FakeConnectivity([ConnectivityResult.wifi]));

    await status.start();

    expect(status.online, isTrue);
  });

  test('sem nenhuma rede, está offline', () async {
    final status =
        ConnectionStatus(FakeConnectivity([ConnectivityResult.none]));

    await status.start();

    expect(status.online, isFalse);
  });

  test('avisa quando a conexão cai e quando volta', () async {
    final connectivity = FakeConnectivity([ConnectivityResult.mobile]);
    final status = ConnectionStatus(connectivity);
    await status.start();
    final seen = <bool>[];
    status.addListener(() => seen.add(status.online));

    connectivity.changes.add([ConnectivityResult.none]);
    await pumpEventQueue();
    connectivity.changes.add([ConnectivityResult.wifi]);
    await pumpEventQueue();

    expect(seen, [false, true]);
    status.dispose();
  });

  test('mudança para o mesmo estado não notifica', () async {
    final connectivity = FakeConnectivity([ConnectivityResult.wifi]);
    final status = ConnectionStatus(connectivity);
    await status.start();
    var notified = 0;
    status.addListener(() => notified++);

    connectivity.changes.add([ConnectivityResult.mobile]);
    await pumpEventQueue();

    expect(notified, 0);
    status.dispose();
  });
}

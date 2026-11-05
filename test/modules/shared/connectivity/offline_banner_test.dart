import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_gabarito/modules/shared/connectivity/offline_banner.dart';

import '../../../helpers/fake_connection_status.dart';

void main() {
  testWidgets('a faixa aparece sem rede e some quando ela volta',
      (tester) async {
    final status = FakeConnectionStatus(online: false);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => OfflineBanner(status: status, child: child!),
      home: const Text('App'),
    ));

    expect(find.text('Sem conexão com a internet'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);

    status.set(true);
    await tester.pump();

    expect(find.text('Sem conexão com a internet'), findsNothing);
    expect(find.text('App'), findsOneWidget);
  });
}

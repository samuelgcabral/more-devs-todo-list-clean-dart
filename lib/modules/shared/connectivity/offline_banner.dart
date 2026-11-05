import 'package:flutter/material.dart';

import 'connection_status.dart';

/// Faixa no topo do app enquanto o aparelho estiver sem rede.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.status, required this.child});

  final ConnectionStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: status,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Column(
          children: [
            if (!status.online)
              Material(
                color: colorScheme.errorContainer,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 18,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sem conexão com a internet',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              // Com a faixa ocupando o topo, a página não precisa mais
              // desviar da barra de status.
              child: MediaQuery.removePadding(
                context: context,
                removeTop: !status.online,
                child: child!,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

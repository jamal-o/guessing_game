import 'package:flutter/material.dart';
import 'socket_client.dart';

class SocketClientProvider extends InheritedWidget {
  final SocketClient socketClient;

  const SocketClientProvider({
    Key? key,
    required Widget child,
    required this.socketClient,
  }) : super(key: key, child: child);

  static SocketClientProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SocketClientProvider>();
  }

  @override
  bool updateShouldNotify(SocketClientProvider oldWidget) {
    // You can customize this if you want to notify dependents on changes
    return socketClient != oldWidget.socketClient;
  }
}

extension Socket on BuildContext {
  SocketClient get socketClient {
    final provider = SocketClientProvider.of(this);
    if (provider == null) {
      throw Exception('SocketClientProvider not found in context');
    }
    return provider.socketClient;
  }
}

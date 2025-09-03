import 'package:flutter/material.dart';

import 'package:guessing_game/pages/create_or_join_page.dart';
import 'package:guessing_game/pages/game_page.dart';
import 'package:guessing_game/pages/home_page.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/socket_client.dart';

void main() {
  runApp(SocketClientProvider(
    socketClient: SocketClient(),
    child: MaterialApp(
      title: 'Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        RouteNames.homePage: (context) => const HomePage(),
        RouteNames.createOrJoinPage: (context) => const CreateOrJoinPage(),
        RouteNames.gamePage: (context) => const GamePage(),
      },
    ),
  ));
}

class RouteNames {
  static const homePage = '/';
  static const createOrJoinPage = '/create_or_join';
  static const gamePage = '/game';
}

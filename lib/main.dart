import 'package:flutter/material.dart';

import 'package:guessing_game/pages/create_or_join_page.dart';
import 'package:guessing_game/pages/game_page.dart';
import 'package:guessing_game/pages/home_page.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/socket_client.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var socketClient = SocketClient();
  runApp(SocketClientProvider(
    socketClient: socketClient,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: 'Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      onGenerateRoute: (settings) {
        bool isAuthenticated = socketClient.isConnected.value;

        if (!isAuthenticated) {
          return MaterialPageRoute(builder: (_) => HomePage());
        }

        switch (settings.name) {
          case RouteNames.homePage:
            return MaterialPageRoute(builder: (_) => HomePage());
          case RouteNames.createOrJoinPage:
            return MaterialPageRoute(builder: (_) => CreateOrJoinPage());
          case RouteNames.gamePage:
            return MaterialPageRoute(
              builder: (context) => GamePage(),
            );
          default:
            return MaterialPageRoute(builder: (_) => CreateOrJoinPage());
        }
      },
      // routes: {
      //   RouteNames.homePage: (context) => const HomePage(),
      //   RouteNames.createOrJoinPage: (context) => const CreateOrJoinPage(),
      //   RouteNames.gamePage: (context) => const GamePage(),
      // },
    ),
  ));
}

class RouteNames {
  static const homePage = '/';
  static const createOrJoinPage = '/create_or_join';
  static const gamePage = '/game';
}

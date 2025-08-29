import 'package:flutter/material.dart';
import 'package:guessing_game/create_or_join_page.dart';
import 'package:guessing_game/home_page.dart';
import 'package:guessing_game/models.dart';
import 'package:guessing_game/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(MaterialApp(
    title: 'Guessing Game',
    theme: ThemeData(
      primarySwatch: Colors.indigo,
    ),
    routes: {
      '/': (context) => const HomePage(),
      '/create_or_join': (context) => const CreateOrJoinPage(),
      '/game': (context) => const HomePage(),
    },
  ));
}

import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/pages/create_or_join_page.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SocketClient socketClient;

  @override
  void initState() {
    super.initState();
    final socketClient = context.socketClient;
  }

  String username = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView(
        children: [
          const Center(
            child: Text('Welcome to the Guessing Game!'),
          ),
          ReactiveTextField(
            hintText: "Input a username",
            text: username,
            onChanged: (value) {
              setState(() {
                username = value;
              });
            },
          ),
          TextButton(
              onPressed: () {
                socketClient.connect(
                    username: username,
                    alert: (message, [isError = false]) async {
                      if (socketClient.isConnected.value) {
                        alert(message);
                        await Future.delayed(Durations.long2);
                        Navigator.pushReplacementNamed(
                            context, RouteNames.createOrJoinPage);
                      } else {
                        alert(message, isError);
                      }
                    });
              },
              child: Text('Connect to Server')),
        ],
      ),
    );
  }

  void alert(String message, [bool isError = false]) {
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      content: Text(message,
          style: TextStyle(
            color: isError ? Colors.red : Colors.black,
          )),
      actions: [],
    ));
  }
}

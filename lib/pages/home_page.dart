import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/socket_client.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  String username = "";
  @override
  Widget build(BuildContext context) {
    final socketClient = context.socketClient;
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
                if (username.isEmpty) {
                  alert("Please enter your username", true);
                  return;
                }
                socketClient.connect(
                  username: username,
                );

                socketClient.isConnected.addListener(() async {
                  final isConnected = socketClient.isConnected.value;
                  final message =
                      isConnected ? "Connected to server." : "Disconnected.";
                  final isError = !isConnected;
                  if (socketClient.isConnected.value) {
                    alert(message);
                    await Future.delayed(Durations.long2);
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, RouteNames.createOrJoinPage);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(
              color: isError ? Colors.red : Colors.black,
            )),
      ),
    );
  }
}

AlertCallback alertCallback(BuildContext context)  {
  return (String message, [bool isError = false]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: TextStyle(
                color: isError ? Colors.red : Colors.black,
              )),
        ),
      );
    };
}

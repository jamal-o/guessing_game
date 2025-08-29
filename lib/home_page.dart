import 'package:flutter/material.dart';
import 'package:guessing_game/create_or_join_page.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  @override
  Widget build(BuildContext context) {
    SocketClient socketClient = SocketClient();
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
                try {
                  socketClient.initSocket(username: username);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateOrJoinPage()),
                  );
                } catch (e) {
                  alert("Error connecting to server: $e");
                }
              },
              child: Text('Connect to Server')),
        ],
      ),
    );
  }

  void alert(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

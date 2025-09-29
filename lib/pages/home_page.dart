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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      socketClient.isConnected.addListener(navigateOnConnected);
    });
  }

  late SocketClient socketClient;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketClient = context.socketClient;
  }

  @override
  void dispose() {
    socketClient.isConnected.removeListener(navigateOnConnected);
    super.dispose();
  }

  void navigateOnConnected() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.createOrJoinPage);
  }

  AlertCallback get alert => alertCallback(context);

  String username = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Text('Welcome to the Guessing Game!',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          SizedBox(
            height: 24,
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
          SizedBox(
            height: 12,
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

                // socketClient.isConnected
                //     .addListener(() => isConnectedListener(socketClient));
              },
              child: const Text('Connect to Server')),
        ],
      ),
    );
  }

  // void isConnectedListener(SocketClient socketClient) async {
  //   final isConnected = socketClient.isConnected.value;
  //   final message = isConnected ? "Connected to server." : "Disconnected.";
  //   final isError = !isConnected;
  //   if (socketClient.isConnected.value) {
  //     alert(message);
  //     await Future.delayed(Durations.long2);
  //     if (!context.mounted) return;
  //     Navigator.pushNamed(context, RouteNames.createOrJoinPage);
  //   } else {
  //     alert(message, isError);
  //   }
  // }
}

AlertCallback alertCallback(BuildContext context) {
  return (String message, [bool isError = false]) {
    if (!context.mounted) return;
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

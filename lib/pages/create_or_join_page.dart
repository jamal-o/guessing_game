import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';

class CreateOrJoinPage extends StatefulWidget {
  const CreateOrJoinPage({super.key});

  @override
  State<CreateOrJoinPage> createState() => _CreateOrJoinPageState();
}

class _CreateOrJoinPageState extends State<CreateOrJoinPage> {
  String roomId = '';

  @override
  Widget build(BuildContext context) {
    final socketClient = context.socketClient;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create or Join Room'),
      ),
      body: ListenableBuilder(
          listenable: Listenable.merge([socketClient.rooms]),
          builder: (context, child) {
            return ListView(
              children: [
                const Center(
                  child: Text('Create or Join Rooms'),
                ),
                TextButton(
                    onPressed: () {
                      socketClient.createGame(alert: alert);
                    },
                    child: const Text('Create Room')),
                ReactiveTextField(
                  hintText: "Input room Code",
                  text: roomId,
                  onChanged: (value) {
                    setState(() {
                      roomId = value;
                    });
                  },
                ),
                TextButton(onPressed: () {}, child: const Text('Join Room')),

                //////////////////////////////////
                ///
                ValueListenableBuilder(
                    valueListenable: socketClient.rooms,
                    builder: (context, value, child) {
                      final rooms = value;
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200),
                          itemCount: socketClient.rooms.value.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => {
                                //join room navigate to page
                              },
                              child: const Card(
                                child: Text("Room Id"),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ],
            );
          }),
    );
  }

  void alert(String message, [bool isSuccess = true]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    Navigator.of(context).pushNamed(RouteNames.gamePage);
  }
}

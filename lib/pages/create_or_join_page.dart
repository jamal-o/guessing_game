import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/pages/home_page.dart';
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
                TextButton(
                    onPressed: () {
                      socketClient.createGame(alert: alert);
                    },
                    child: const Text('Create Room')),
                Divider(),
                const Center(
                  child: Text('Join Rooms'),
                ),
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
                                socketClient.joinRoom(
                                    room: rooms[index], alert: alert)
                              },
                              child: Card(
                                child: Text(rooms[index].roomId),
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

  void alert(String message, [bool isError = false]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (!isError) {
      Navigator.of(context).pushNamed(RouteNames.gamePage);
    }
  }
}

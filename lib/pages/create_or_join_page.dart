import 'package:flutter/material.dart';
import 'package:guessing_game/socket_client_provider.dart';

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
      body: ListView(
        children: [
          TextButton(
              onPressed: () {
                socketClient.createGame();
              },
              child: const Text('Create Room')),
          const Divider(),
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
                              room: rooms[index])
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
      ),
    );
  }

  // void alert(bool isError) {
   

  //   if (!isError) {
  //     Navigator.of(context).pushNamed(RouteNames.gamePage);
  //   }
  // }
}

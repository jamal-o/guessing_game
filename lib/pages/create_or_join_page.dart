import 'dart:math';

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
                      final room = rooms[index];
                      return Card(
                        color: _getRandomColor(),
                        child: InkWell(
                          onTap: () =>
                              {socketClient.joinRoom(room: rooms[index])},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Room: ${room.roomId}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Players: ${room.activePlayers.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
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

  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      1.0,
    );
  }
}

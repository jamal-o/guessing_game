import 'package:flutter/material.dart';
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
    SocketClient socketClient = SocketClient();
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
                TextButton(onPressed: () {}, child: Text('Create Room')),
                ReactiveTextField(
                  hintText: "Input room Code",
                  text: roomId,
                  onChanged: (value) {
                    setState(() {
                      roomId = value;
                    });
                  },
                ),
                TextButton(onPressed: () {}, child: Text('Join Room')),

                //////////////////////////////////
                ///
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200),
                  itemCount: socketClient.rooms.value.length,
                  itemBuilder: (context, index) {
                    InkWell(
                      onTap: () => {
                        //join room navigate to page
                      },
                      child: Card(
                        child: Text("Room Id"),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
    );
  }

  void alert(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}


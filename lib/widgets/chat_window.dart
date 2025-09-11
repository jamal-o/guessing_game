import 'package:flutter/material.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';

class ChatWindow extends StatefulWidget {
  const ChatWindow({
    super.key,
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  String message = "";
  final controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.socketClient.chatMessages.addListener(() {
        controller.jumpTo(controller.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketClient = context.socketClient;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chat", style: Theme.of(context).textTheme.titleMedium),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: socketClient.chatMessages,
              builder: (context, messages, child) {
                return ListView.builder(
                  controller: controller,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(messages[index].text),
                    );
                  },
                );
              }),
        ),
        ReactiveTextField(
          hintText: "Type a message...",
          text: message,
          onChanged: (value) {
            setState(() {
              message = value;
            });
          },
          trailing: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              socketClient.sendChat(
                message,
              );
              setState(() {
                message = "";
              });

              // final position = controller.positions.last;
              // controller.animateTo(position.maxScrollExtent,
              //     duration: Durations.medium1, curve: Curves.easeIn);
            },
          ),
        ),
      ],
    );
  }
}

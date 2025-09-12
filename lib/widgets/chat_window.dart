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
  Widget build(BuildContext context) {
    final socketClient = context.socketClient;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chat",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: socketClient.chatMessages,
                builder: (context, messages, child) {
                  return ListView.builder(
                    controller: controller,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                message.text,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                message.timeString,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
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
                socketClient.sendChat(message);
                setState(() {
                  message = "";
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

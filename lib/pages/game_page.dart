import 'package:flutter/material.dart';
import 'package:guessing_game/pages/home_page.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    SocketClient socketClient = SocketClient();

    // Responsive layout
    var screenWidth = MediaQuery.sizeOf(context).width;
    var isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Room'),
      ),
      drawer: isMobile ? ScaffoldDrawer() : null,
      body: Builder(builder: (context) {
        return ValueListenableBuilder(
          valueListenable: socketClient.isGameMaster,
          builder: (context, isGameMaster, child) {
            return isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isGameMaster)
                        const Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GameMaster(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuestionGuessWidget(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Add a floating button for chat and scoreboard
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isGameMaster)
                        const Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GameMaster(),
                          ),
                        ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ChatWindow(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Scoreboard(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuestionGuessWidget(),
                        ),
                      ),
                    ],
                  );
          },
        );
      }),
      floatingActionButton: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'chat',
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 400,
                          child: ChatWindow(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'scoreboard',
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Scoreboard'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 300,
                          child: Scoreboard(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
    );
  }

  late final alert = alertCallback(context);
}

class ScaffoldDrawer extends StatelessWidget {
  const ScaffoldDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text('Menu', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 400,
                    child: ChatWindow(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Scoreboard'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 300,
                    child: Scoreboard(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GameMaster extends StatefulWidget {
  const GameMaster({super.key});

  @override
  State<GameMaster> createState() => _GameMasterState();
}

class _GameMasterState extends State<GameMaster> {
  String question = "";

  String answer = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Game Master"),
        const Text("Add questions here"),
        ReactiveTextField(
            hintText: "Question",
            text: question,
            onChanged: (value) => question = value),
        ReactiveTextField(
            hintText: "Answer",
            text: answer,
            onChanged: (value) => answer = value),
        TextButton(onPressed: () {}, child: const Text("Add Question")),
      ],
    );
  }
}

// Chat Window Widget
class ChatWindow extends StatefulWidget {
  const ChatWindow({
    super.key,
  });

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  String message = "";
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(messages[index]),
                  ),
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
              socketClient.sendChat(message, alertCallback(context));
            },
          ),
        ),
      ],
    );
  }
}

// Scoreboard Widget
class Scoreboard extends StatelessWidget {
  const Scoreboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final socketClient = context.socketClient;
    return ValueListenableBuilder(
        valueListenable: socketClient.scoreboard,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Scoreboard",
                  style: Theme.of(context).textTheme.titleMedium),
              // ...scores.entries.map(
              Expanded(
                child: ListView.builder(
                  itemCount: socketClient.scoreboard.value.length, 
                  itemBuilder: (context, i) {
                  final record = context.socketClient.scoreboard.value[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(record.userName),
                        Text(record.score.toString()),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        });
  }
}

// Question & Guess Widget
class QuestionGuessWidget extends StatefulWidget {
  const QuestionGuessWidget({
    super.key,
  });

  @override
  State<QuestionGuessWidget> createState() => _QuestionGuessWidgetState();
}

class _QuestionGuessWidgetState extends State<QuestionGuessWidget> {
  String guess = "";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: context.socketClient.question,
        builder: (context, question, child) {
          return question == null
              ? Card(child: Text("No active uestion"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Question:",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(question.text,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    ReactiveTextField(
                      hintText: "Your guess...",
                      text: guess,
                      onChanged: (value) {
                        setState(() {
                          guess = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Submit Guess"),
                    ),
                  ],
                );
        });
  }
}

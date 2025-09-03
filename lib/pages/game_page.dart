import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
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
    SocketClient socketClient = context.socketClient;

    // Responsive layout
    var screenWidth = MediaQuery.sizeOf(context).width;
    var isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              socketClient.disconnect();
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.createOrJoinPage,
                (route) => route.isFirst,
              );
            },
          ),
        ],
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
                                  child: ScoreboardWidget(),
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
                          child: ScoreboardWidget(),
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
                    child: ScoreboardWidget(),
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
        TextButton(
            onPressed: () {
              if (question.isEmpty || answer.isEmpty) {
                final alert = alertCallback(context);
                alert("Complete the question");
                return;
              }
              final payload = Question(text: question, answer: answer);

              context.socketClient
                  .addQuestion(payload, 60, alertCallback(context));
            },
            child: const Text("Add Question")),
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
              socketClient.sendChat(message, alertCallback(context));
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

// Scoreboard Widget
class ScoreboardWidget extends StatelessWidget {
  const ScoreboardWidget({
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
              if (value?.gameMaster != null) ...[
                PlayerTile(
                  player: value!.gameMaster!,
                  isGameMaster: true,
                ),
              ],
              Expanded(
                child: ListView.builder(
                    itemCount: value?.players.length ?? 0,
                    itemBuilder: (context, i) {
                      final player = value?.players[i];
                      if (value?.gameMaster != null &&
                          player?.id == value?.gameMaster?.id)
                        return SizedBox.shrink();
                      return PlayerTile(
                        player: player!,
                        isGameMaster: false,
                      );
                    }),
              ),
            ],
          );
        });
  }
}

class PlayerTile extends StatelessWidget {
  const PlayerTile({super.key, required this.player, required isGameMaster});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${player.name} 👑"),
          Text(player.score.toString()),
        ],
      ),
    );
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

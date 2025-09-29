import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/pages/home_page.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/chat_window.dart';
import 'package:guessing_game/widgets/game_master.dart';
import 'package:guessing_game/widgets/question_guess_widget.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';
import 'package:guessing_game/socket_client.dart';
import 'package:guessing_game/widgets/scaffold_drawer.dart';
import 'package:guessing_game/widgets/scoreboard_widget.dart';

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
        title: Text('Game Room: ${socketClient.roomId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              socketClient.leaveRoom();
              Navigator.pushReplacementNamed(
                context,
                RouteNames.createOrJoinPage,
              );
            },
          ),
        ],
      ),
      drawer: isMobile ? const ScaffoldDrawer() : null,
      body: Builder(builder: (context) {
        return ValueListenableBuilder(
          valueListenable: socketClient.isGameMaster,
          builder: (context, isGameMaster, child) {
            return isMobile
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                        const Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: QuestionGuessWidget(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Add a floating button for chat and scoreboard
                      ],
                    ),
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
                      const Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ChatWindow(),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ScoreboardWidget(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
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
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
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
}

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    required this.isGameMaster,
  });

  final Player player;
  final bool isGameMaster;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${player.name}${isGameMaster ? " (Game Master)" : ""}"),
          Text(player.score.toString()),
        ],
      ),
    );
  }
}

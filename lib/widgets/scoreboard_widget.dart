import 'package:flutter/material.dart';
import 'package:guessing_game/pages/game_page.dart';
import 'package:guessing_game/socket_client_provider.dart';

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
                          player?.id == value?.gameMaster?.id) {
                        return const SizedBox.shrink();
                      }
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

import 'package:flutter/material.dart';
import 'package:guessing_game/main.dart';
import 'package:guessing_game/widgets/chat_window.dart';
import 'package:guessing_game/widgets/scoreboard_widget.dart';

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
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Scoreboard'),
            onTap: () {
              Navigator.pop(context);
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
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Scoreboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, RouteNames.createOrJoinPage);
            },
          ),
        ],
      ),
    );
  }
}

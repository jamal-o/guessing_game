import 'package:flutter/material.dart';
import 'package:guessing_game/pages/home_page.dart';
import 'package:guessing_game/socket_client.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';

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
    return ValueListenableBuilder(
        valueListenable: context.socketClient.question,
        builder: (context, value, child) {
          return Column(
            children: [
              const Text("Game Master"),
              if (value == null) ...[
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

                      context.socketClient.addQuestion(
                        payload,
                        5,
                      );

                      setState(() {
                        question = "";
                        answer = "";
                      });
                    },
                    child: const Text("Add Question")),
              ],
              if (value != null) Text('Question in progress'),
            ],
          );
        });
  }
}

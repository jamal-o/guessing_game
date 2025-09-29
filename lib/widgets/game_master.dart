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
  String duration = "";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: context.socketClient.question,
        builder: (context, value, child) {
          return Column(
            children: [
              Text(
                "Game Master",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 12,
              ),
              if (value == null) ...[
                Text(
                  "Add questions here",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ReactiveTextField(
                    hintText: "Question",
                    text: question,
                    onChanged: (value) => question = value),
                SizedBox(
                  height: 12,
                ),
                ReactiveTextField(
                    hintText: "Answer",
                    text: answer,
                    onChanged: (value) => answer = value),
                SizedBox(
                  height: 12,
                ),
                ReactiveTextField(
                  hintText: "Duration",
                  text: duration,
                  textInputType: TextInputType.number,
                  onChanged: (value) => duration = value,
                ),
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
                        int.tryParse(duration) ?? 20,
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

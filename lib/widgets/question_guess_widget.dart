import 'package:flutter/material.dart';
import 'package:guessing_game/socket_client_provider.dart';
import 'package:guessing_game/widgets/reactive_text_field.dart';

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
              ? const Text(
                  "No active Question",
                  textAlign: TextAlign.center,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Question:",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(question.text,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    if (!context.socketClient.isGameMaster.value) ...[
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
                        onPressed: () {
                          context.socketClient.guess(
                            guess,
                          );
                          setState(() {
                            guess = "";
                          });
                        },
                        child: const Text("Submit Guess"),
                      ),
                    ]
                  ],
                );
        });
  }
}

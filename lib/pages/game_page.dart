import 'package:flutter/material.dart';
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
    bool isGameMaster = false; // Should be set based on actual user role
    String currentQuestion = "What is the capital of France?";
    String userGuess = "";
    List<String> chatMessages = ["Welcome to the game!", "Good luck!"];
    Map<String, int> scoreboard = {"Alice": 10, "Bob": 7, "You": 5};

    // Responsive layout
    var screenWidth = MediaQuery.of(context).size.width;
    var isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Room'),
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text('Menu', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chat'),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 400,
                            child: ChatWindow(messages: chatMessages),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.leaderboard),
                    title: Text('Scoreboard'),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 300,
                            child: Scoreboard(scores: scoreboard),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isGameMaster)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GameMaster(),
                      ),
                    ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QuestionGuessWidget(
                        question: currentQuestion,
                        guess: userGuess,
                        onGuessChanged: (value) {
                          // setState should be called in a real implementation
                          userGuess = value;
                        },
                        onSubmit: () {
                          alert("Guess submitted: $userGuess");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Add a floating button for chat and scoreboard
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isGameMaster)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                              child: ChatWindow(messages: chatMessages),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Scoreboard(scores: scoreboard),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QuestionGuessWidget(
                        question: currentQuestion,
                        guess: userGuess,
                        onGuessChanged: (value) {
                          // setState should be called in a real implementation
                          userGuess = value;
                        },
                        onSubmit: () {
                          alert("Guess submitted: $userGuess");
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'chat',
                  icon: Icon(Icons.chat),
                  label: Text('Chat'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 400,
                          child: ChatWindow(messages: chatMessages),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'scoreboard',
                  icon: Icon(Icons.leaderboard),
                  label: Text('Scoreboard'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 300,
                          child: Scoreboard(scores: scoreboard),
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

  void alert(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        Text("Game Master"),
        Text("Add questions here"),
        ReactiveTextField(
            hintText: "Question",
            text: question,
            onChanged: (value) => question = value),
        ReactiveTextField(
            hintText: "Answer",
            text: answer,
            onChanged: (value) => answer = value),
        TextButton(onPressed: () {}, child: Text("Add Question")),
      ],
    );
  }
}

// Chat Window Widget
class ChatWindow extends StatelessWidget {
  final List<String> messages;
  const ChatWindow({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chat", style: Theme.of(context).textTheme.titleMedium),
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(messages[index]),
            ),
          ),
        ),
        ReactiveTextField(
          hintText: "Type a message...",
          text: "",
          onChanged: (value) {},
          trailing: IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // TODO: Send chat message
            },
          ),
        ),
      ],
    );
  }
}

// Scoreboard Widget
class Scoreboard extends StatelessWidget {
  final Map<String, int> scores;
  const Scoreboard({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Scoreboard", style: Theme.of(context).textTheme.titleMedium),
        ...scores.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(e.value.toString()),
                ],
              ),
            )),
      ],
    );
  }
}

// Question & Guess Widget
class QuestionGuessWidget extends StatelessWidget {
  final String question;
  final String guess;
  final ValueChanged<String> onGuessChanged;
  final VoidCallback onSubmit;
  const QuestionGuessWidget({
    super.key,
    required this.question,
    required this.guess,
    required this.onGuessChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current Question:",
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Text(question, style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 16),
        ReactiveTextField(
          hintText: "Your guess...",
          text: guess,
          onChanged: onGuessChanged,
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text("Submit Guess"),
        ),
      ],
    );
  }
}

// ignore_for_file: constant_identifier_names

enum EVENTS {
  //player
  player$guess,

  //game_master
  user$create_game,
  user$add_question,
  user$new_question,

  //user
  user$chat,
  user$exit_room,
  user$join_room,

  //game
  game$update_scoreboard,
  game$question_timeout,
  game$winner,
  game$rooms,
  game$end_game,
  game$error,
}

class Response {
  final String message;
  final bool success;
  final Map<String, dynamic>? data;

  Response({required this.message, required this.success, required this.data});
}


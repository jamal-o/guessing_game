// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import 'package:guessing_game/models.dart';
import 'package:guessing_game/pages/game_page.dart';

typedef AlertCallback = void Function(String message, [bool isError]);

class SocketClient {
  SocketClient();

  IO.Socket? _socket;
  String? roomId;
  final String serverUrl = 'http://localhost:3000';

  // ValueNotifiers for state
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<bool> isGameMaster = ValueNotifier(false);
  final ValueNotifier<List<Room>> rooms = ValueNotifier([]);
  final ValueNotifier<Scoreboard?> scoreboard = ValueNotifier(null);
  final ValueNotifier<List<Chat>> chatMessages = ValueNotifier([]);
  final ValueNotifier<Question?> question = ValueNotifier(null);

  String? _username;

  void connect({
    required String username,
  }) {
    _username = username;
    // Socket is not connected until connect() is called
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // manual connect
          .setExtraHeaders({'username': username})
          .build(),
    );
    _registerSocketEvents();

    _socket!.connect();
  }

  void leaveRoom() {
    _socket?.emit(EVENTS.user$exit_room.name, {"roomId": roomId});
  }

  void disconnect() {
    _socket?.disconnect();
    isConnected.value = false;
  }

  void _registerSocketEvents() {
    if (_socket == null) return;
    _socket!.onConnect((_) {
      _logEvent("Connect", null);

      isConnected.value = true;
    });
    _socket!.onDisconnect((_) {
      _logEvent("Disconnect", null);
      isConnected.value = false;
    });

    _socket!.on(EVENTS.user$chat.name, (res) {
      _logEvent(EVENTS.user$chat.name, res);

      final response = ResponseDTO.fromJson(res, Chat.fromJson);
      chatMessages.value = [...chatMessages.value, response.data];
    });

    _socket!.on(EVENTS.game$rooms.name, (res) {
      _logEvent(EVENTS.game$rooms.name, res);

      final response = ResponseDTO.fromJson(
          res,
          (data) => (data["rooms"] as List)
              .map((room) => Room.fromJson(room))
              .toList());
      rooms.value = response.data;
    });

    _socket!.on(EVENTS.game$new_question.name, (res) {
      _logEvent(EVENTS.game$new_question.name, res);

      final response = ResponseDTO.fromJson(res, Question.fromJson);
      question.value = response.data;
    });

    _socket!.on(EVENTS.user$add_question.name, (res) {
      _logEvent(EVENTS.user$add_question.name, res);
    });

    // _socket!.on(EVENTS.player$guess.name, (res) {
    //   _logEvent(EVENTS.player$guess.name, res);

    //   throw UnimplementedError();
    // });

    _socket!.on(EVENTS.game$update_scoreboard.name, (res) {
      _logEvent(EVENTS.game$update_scoreboard.name, res);

      final response = ResponseDTO.fromJson(res, Scoreboard.fromJson);

      scoreboard.value = response.data;

      isGameMaster.value =
          scoreboard.value?.gameMaster?.id == (_socket?.id ?? "disconnected");
    });

    _socket!.on(EVENTS.game$question_timeout.name, (res) {
      _logEvent(EVENTS.game$question_timeout.name, res);

      //TODO:
    });

    _socket!.on(EVENTS.game$winner.name, (res) {
      _logEvent(EVENTS.game$winner.name, res);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.game$error.name, (res) {
      _logEvent(EVENTS.game$error.name, res);

      //TODO: handle error
    });

    _socket!.on('error', (msg) {
      _logEvent("error", msg);
    });
  }

  void _logEvent(String event, dynamic data) {
    print("Event: $event, Data: $data");
  }

  void joinRoom({
    required Room room,
    required AlertCallback alert,
  }) {
    if (_socket == null) {
      return;
    }
    final roomCode = room.roomId;
    _socket!.emitWithAck(
      EVENTS.user$join_room.name,
      {"roomId": roomCode, "username": _username},
      ack: (success) {
        print("join room ack");
        if (success) {
          roomId = roomCode;
          alert("Joined room successfully");
        } else {
          alert("Error joining room", true);
        }
      },
    );
  }

  void createGame({
    required AlertCallback alert,
  }) {
    if (_socket == null) {
      alert("Socket not initialized.", true);
      return;
    }
    _socket!.emitWithAck(
      EVENTS.user$create_game.name,
      {"username": this._username},
      ack: (roomId) {
        print("Create Game Ack: $roomId");
        if (roomId != null) {
          this.roomId = roomId;
          alert(
            "Game created successfully",
          );
        } else {
          alert(
            "Failed to create game.",
            true,
          );
        }
      },
    );
  }

  void sendChat(String message, AlertCallback alert) {
    if (_socket == null || roomId == null) {
      alert(
        "Not connected to any game.",
        true,
      );
      return;
    }
    _socket!.emit(EVENTS.user$chat.name, {
      "message": {
        "text": message,
        "time": DateTime.now().toString(),
        "username": _username
      },
      "roomId": roomId
    });
  }

  void addQuestion(Question payload, int duration, AlertCallback alert) {
    if (_socket == null || roomId == null) {
      alert(
        "Not connected to any game.",
        true,
      );
      return;
    }
    _socket!.emit(EVENTS.user$add_question.name, {
      "question": {
        "text": payload.text,
        "answer": payload.answer,
      },
      "roomId": roomId,
      "duration": duration
    });
  }
}

class Room {
  final String roomId;
  final String created;
  final String activePlayers;
  Room({
    required this.roomId,
    required this.created,
    required this.activePlayers,
  });

  factory Room.fromJson(Json json) {
    return Room(
      roomId: json['roomId'] ?? '',
      created: json['created'] ?? '',
      activePlayers: json['activePlayers']?.toString() ?? '',
    );
  }
}

enum PlayerStatus { online, offline, disconnected }

class Player {
  final String name;
  final String id;
  final PlayerStatus status;
  final int score;
  final int questionsAttempted;
  final int questionsCorrect;

  Player(
      {required this.name,
      required this.id,
      required this.status,
      required this.score,
      required this.questionsAttempted,
      required this.questionsCorrect});

  factory Player.fromJson(Json json) {
    return Player(
        name: json["name"],
        id: json["id"],
        status: PlayerStatus.values.byName(json["status"]),
        score: json["score"],
        questionsAttempted: json["questionsAttempted"],
        questionsCorrect: json["questionsCorrect"]);
  }
}

class Scoreboard {
  final Player? gameMaster;
  final List<Player> players;

  Scoreboard({required this.gameMaster, required this.players});

  factory Scoreboard.fromJson(Json json) {
    return Scoreboard(
        gameMaster: Player.fromJson(json["gameMaster"]),
        players: (json["players"] as List)
            .map((player) => Player.fromJson(player))
            .toList());
  }
}

class ScoreboardRow {
  final String username;
  final int score;

  ScoreboardRow({required this.username, required this.score});

  @override
  factory ScoreboardRow.fromJson(Map<String, dynamic> json) {
    return ScoreboardRow(username: json['username'], score: json['score']);
  }
}

typedef Json = Map<String, dynamic>;

class Question {
  final String text;
  final String? answer;

  Question({required this.text, this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(text: json['text']);
  }
}

class Chat {
  final String text;
  final String username;
  final String time;

  Chat({
    required this.text,
    required this.username,
    required this.time,
  });

  @override
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
        text: json["text"], username: json['username'], time: json['time']);
  }
}

class ResponseDTO<T> {
  final bool success;
  final String message;
  final T data;

  ResponseDTO(
      {required this.success, required this.message, required this.data});

  factory ResponseDTO.fromJson(Json json, T Function(Json) transformer) {
    return ResponseDTO(
        success: json['success'],
        message: json["message"],
        data: transformer(json['data']));
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:guessing_game/models.dart';
import 'package:guessing_game/pages/game_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

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
  final ValueNotifier<List<ScoreboardRow>> scoreboard = ValueNotifier([]);
  final ValueNotifier<List<String>> chatMessages = ValueNotifier([]);
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

    _socket!.on(EVENTS.user$chat.name, (message) {
      _logEvent(EVENTS.user$chat.name, message);

      chatMessages.value = [...chatMessages.value, message.toString()];
    });

    _socket!.on(EVENTS.game$rooms.name, (data) {
      _logEvent(EVENTS.game$rooms.name, data);

      if (data is List) {
        rooms.value = data.map((e) => Room.fromJson(e)).toList();
      }
    });

    _socket!.on(EVENTS.user$new_question.name, (data) {
      _logEvent(EVENTS.user$new_question.name, data);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.user$add_question.name, (data) {
      _logEvent(EVENTS.user$add_question.name, data);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.game$rooms.name, (data) {
      _logEvent(EVENTS.game$rooms.name, data);
      rooms.value = (data as List<Map<String, dynamic>>)
          .map((element) => Room.fromJson(element))
          .toList();
    });

    _socket!.on(EVENTS.player$guess.name, (data) {
      _logEvent(EVENTS.player$guess.name, data);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.game$update_scoreboard.name, (data) {
      _logEvent(EVENTS.game$update_scoreboard.name, data);

      scoreboard.value = data;
    });

    _socket!.on(EVENTS.game$question_timeout.name, (data) {
      _logEvent(EVENTS.game$question_timeout.name, data);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.game$winner.name, (data) {
      _logEvent(EVENTS.game$winner.name, data);

      throw UnimplementedError();
    });

    _socket!.on(EVENTS.game$error.name, (data) {
      _logEvent(EVENTS.game$error.name, data);

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
    required String userName,
    required String roomCode,
    required AlertCallback alert,
  }) {
    if (_socket == null) {
      return;
    }
    _socket!.emitWithAck(
      EVENTS.user$join_room.name,
      {"roomId": roomCode, "username": userName},
      ack: (success) {
        if (success) {
          roomId = roomCode;
        } else {
          alert("");
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
    _socket!
        .emit(EVENTS.user$chat.name, {"message": message, "roomId": roomId});
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

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'] ?? '',
      created: json['created'] ?? '',
      activePlayers: json['activePlayers']?.toString() ?? '',
    );
  }
}

class ScoreboardRow {
  final String userName;
  final int score;

  ScoreboardRow({required this.userName, required this.score});
}

class Question {
  final String text;

  Question({required this.text});
}

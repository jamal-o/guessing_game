// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:guessing_game/models.dart';
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
  final ValueNotifier<List<Room>> rooms = ValueNotifier([]);
  final ValueNotifier<List<String>> chatMessages = ValueNotifier([]);

  String? _username;

  void connect({required String username, required AlertCallback alert}) {
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
      isConnected.value = true;
    });
    _socket!.onDisconnect((_) {
      isConnected.value = false;
    });

    _socket!.onAny((event, data) {
      print("Event: $event, Data: $data");
    });

    _socket!.on(EVENTS.user$chat.name, (message) {
      chatMessages.value = [...chatMessages.value, message.toString()];
    });
    // Example: handle room list updates
    _socket!.on('rooms', (data) {
      if (data is List) {
        rooms.value = data.map((e) => Room.fromJson(e)).toList();
      }
    });

    _socket!.on('error', (msg) {});
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
    required String username,
    required AlertCallback alert,
  }) {
    if (_socket == null) {
      alert("Socket not initialized.", true);
      return;
    }
    _socket!.emitWithAck(
      EVENTS.user$create_game.name,
      {"username": username},
      ack: (roomId) {
        if (roomId != null) {
          this.roomId = roomId;
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

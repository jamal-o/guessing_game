// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:guessing_game/models.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient {
  SocketClient();
  late final Socket socket;

  void initSocket({required String username}) {
    // Dart client
    socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            // .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'username': username}) // optional
            .build());
    socket.onConnect((something) {
      print('connect ${something}');
      socket.emit('msg', 'test');
    });

    // socket.connect();
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));

    socket.onAny((event, data) {
      print("Event: ${event}; Data ${data}");
    });
    socket.on(EVENTS.user$chat.name, (message) {
      print(message);
    });
  }

  String? roomId;
  void joinRoom({required String userName, required String roomCode}) {
    socket.emitWithAck(
      EVENTS.user$join_room.name,
      {"roomId": roomCode, "username": userName},
      ack: (success) => {if (success) roomId = roomCode},
    );
  }

  ValueNotifier<List<Room>> rooms = ValueNotifier([]);

  
  void createGame({required String username}) {
    socket.emitWithAck(
      EVENTS.user$create_game.name,
      {
        "username": username,
      },
      ack: (roomId) => {this.roomId = roomId},
    );
  }

  void chat(Function(String) alert) {
    if (roomId == null) {
      alert("You are not connected to any game");
      return;
    }
    socket.emit(EVENTS.user$chat.name,
        {"message": "Hello from Flutter", "roomId": roomId});
    print("Send message ${EVENTS.user$create_game.name}");
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
}

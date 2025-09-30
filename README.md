# Guessing Game Client

A Flutter-based client application for a real-time multiplayer guessing game where players take turns being the game master and creating questions for others to answer.

## Features

- 🎮 Real-time multiplayer gameplay using WebSocket connections
- 💬 Live chat functionality between players
- 🏠 Room-based game sessions
- 📊 Live score tracking and leaderboard
- 👑 Role-based gameplay (Game Master and Players)
- 🎯 Multiple guess attempts per question
- ⏱️ Timed questions with automatic timeouts
- 🎨 Modern, responsive UI for both web and mobile platforms

## Prerequisites

- Flutter SDK (>= 3.2.5)
- Dart SDK (>= 3.2.5)
- A running instance of the guessing_game_server

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/guessing_game.git
cd guessing_game_client/guessing_game
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

## Dependencies

- `flutter`: The base framework
- `socket_io_client`: For real-time WebSocket communication
- `flex_color_scheme`: For theming and UI styling
- `flutter_lints`: For code quality and consistency

## Game Rules

1. One player becomes the Game Master and creates a question with an answer
2. Other players have 3 attempts to guess the correct answer
3. Players earn 10 points for correct answers
4. Questions have a time limit (default: 60 seconds)
5. Game Master role rotates among players after each question
6. Players can chat during the game

## Project Structure

```
lib/
├── pages/           # Main application pages
├── widgets/         # Reusable UI components
├── apptheme.dart    # App theming configuration
├── main.dart        # Application entry point
├── models.dart      # Data models
├── socket_client.dart       # WebSocket client implementation
└── socket_client_provider.dart  # Socket client state management
```

## Development

To run the project in development mode:

```bash
flutter run -d chrome  # For web
flutter run -d <device-id>  # For mobile devices
```

To build for production:

```bash
flutter build web  # For web
flutter build apk  # For Android
flutter build ios  # For iOS
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## License

This project is open source and available under the MIT License.

## Related Projects

- [guessing_game_server](../guessing_game_server): The Node.js backend server for this application

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Socket.IO Client Documentation](https://pub.dev/packages/socket_io_client)
- [Flex Color Scheme Documentation](https://pub.dev/packages/flex_color_scheme)

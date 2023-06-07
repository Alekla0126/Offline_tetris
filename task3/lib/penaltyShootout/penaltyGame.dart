import 'package:flutter/material.dart' hide Image;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'goalie.dart';
import 'ball.dart';
import 'dart:ui';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: GameWrapper(),
      ),
    ),
  );
}

class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Flame.device.fullScreen();
        Flame.device.setPortrait();
        return GameWidget(game: PenaltyGame());
      },
    );
  }
}

class PenaltyGame extends FlameGame with TapDetector {
  Color gameBackgroundColor = Colors.white; // Renamed field to 'gameBackgroundColor'
  late SpriteComponent background;
  late ScoreLabel scoreLabel;
  late Goalie goalie;
  late Ball player;

  Image? goalieImage;
  Image? soccerBall;
  Image? bgImage;

  int score = 0;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = gameBackgroundColor, // Set the background color
    );
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    await loadImages(); // Load the images asynchronously

    background = SpriteComponent(
      sprite: Sprite(bgImage!),
      position: Vector2.zero(),
      size: Vector2(size.x, size.y),
    );
    add(background);

    player = Ball(
      position: Vector2(size.x / 2, size.y - 200),
      shootCallback: incrementScore,
      sprite: Sprite(soccerBall!),
      game: this, // Pass the game instance
    );
    add(player);

    goalie = Goalie(
      position: Vector2(size.x / 2, 100),
      sprite: Sprite(goalieImage!),
      game: this, // Pass the game instance
    );
    add(goalie);

    // Create and add the score label component
    scoreLabel = ScoreLabel(
      position: NotifyingVector2(size.x - 100, 50), // Create a NotifyingVector2 object
      textStyle: const TextStyle(color: Colors.black, fontSize: 20),
    );
    add(scoreLabel);
  }

  Future<void> loadImages() async {
    bgImage = await Flame.images.load('background.png');
    soccerBall = await Flame.images.load('ball.png');
    goalieImage = await Flame.images.load('goalie.png');
  }

  void incrementScore() {
    if (player.collidesWithGoalie(goalie)) {
      if (gameBackgroundColor != Colors.red) {
        gameBackgroundColor = Colors.red; // Set background color to red on failure
        goalie.stopBall(); // Stop the ball if it collides with the goalie
        player.reset();
        Future.delayed(const Duration(milliseconds: 500), () {
          gameBackgroundColor = Colors.white;
          score++;
          scoreLabel.score = score;
        });
      }
    } else {
      score++;
      scoreLabel.score = score;
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    const double arrowLength = 50.0; // Length of the arrow
    const double arrowWidth = 20.0; // Width of the arrow

    // Check if the player has already chosen the direction
    if (!player.isChoosingDirection) {
      // Player is choosing the direction
      player.startChoosingDirection(info.eventPosition.game);
    } else {
      // Player is shooting the penalty with strength
      player.shootPenalty(info.eventPosition.game);

      // Get the arrow position and direction
      final arrowPosition = player.position - Vector2(arrowLength / 2, arrowLength + 10);
      final arrowDirection = player.shootDirection.normalized();

      // TODO: Implement the logic to handle the arrow position and direction
    }
  }

  bool isColliding = false;
  @override
  void update(double dt) {
    super.update(dt);

    // Check for ball collision with the goalie and handle it
    if (player.collidesWithGoalie(goalie)) {
      goalie.stopBall();
      if (!isColliding) {
        isColliding = true;
        gameBackgroundColor = Colors.red;
        Future.delayed(const Duration(milliseconds: 500), () {
          isColliding = false;
          gameBackgroundColor = Colors.white;
        });
      }
      player.reset();
    }
  }
}

class ScoreLabel extends PositionComponent {
  @override
  final NotifyingVector2 position;
  final TextStyle textStyle;
  int score = 0;

  ScoreLabel({
    required this.position,
    required this.textStyle,
  });

  @override
  void render(Canvas canvas) {
    final textSpan = TextSpan(text: 'Score: $score', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textPosition = Offset(position.x - textPainter.width, position.y);
    textPainter.paint(canvas, textPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
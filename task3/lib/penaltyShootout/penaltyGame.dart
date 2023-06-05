import 'package:flutter/material.dart' hide Image;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWrapper(),
      ),
    ),
  );
}

class GameWrapper extends StatelessWidget {
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
  late SpriteComponent background;
  late Player player;
  late Goalie goalie;
  late ScoreDisplay scoreDisplay;

  Image? bgImage;
  Image? playerImage;
  Image? goalieImage;

  int score = 0;

  @override
  Future<void> onLoad() async {
    await loadImages(); // Load the images asynchronously

    background = SpriteComponent(
      sprite: Sprite(bgImage!),
      position: Vector2.zero(),
      size: Vector2(size.x, size.y),
    );
    add(background);

    player = Player(
      position: Vector2(size.x / 2, size.y - 200),
      shootCallback: incrementScore,
      sprite: Sprite(playerImage!),
      game: this, // Pass the game instance
    );
    add(player);

    goalie = Goalie(
      position: Vector2(size.x / 2, 100),
      sprite: Sprite(goalieImage!),
    );
    add(goalie);

    scoreDisplay = ScoreDisplay(position: Vector2(size.x / 2, 50));
    add(scoreDisplay);
  }

  Future<void> loadImages() async {
    bgImage = await Flame.images.load('background.png');
    playerImage = await Flame.images.load('player.png');
    goalieImage = await Flame.images.load('goalie.png');
  }

  void incrementScore() {
    score++;
    scoreDisplay.updateScore(score);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    // Check if the player has already chosen the direction
    if (!player.isChoosingDirection) {
      // Player is choosing the direction
      player.startChoosingDirection(info.eventPosition.game);
    } else {
      // Player is shooting the penalty with strength
      player.shootPenalty(info.eventPosition.game);
    }
  }
}

class Player extends SpriteComponent {
  late Vector2 shootDirection;
  double shootStrength = 0;
  bool isChoosingDirection = false;
  bool isShooting = false;
  late void Function() shootCallback;
  late final PenaltyGame game; // Add the game reference

  Player({
    required Vector2 position,
    required this.shootCallback,
    required Sprite sprite,
    required this.game, // Pass the game reference
  }) : super(
    position: position,
    size: Vector2(100, 100),
    sprite: sprite,
  );

  void startChoosingDirection(Vector2 initialPosition) {
    isChoosingDirection = true;
    shootDirection = initialPosition - position;
    shootDirection.normalize();
  }

  void shootPenalty(Vector2 finalPosition) {
    if (!isShooting) {
      isShooting = true;
      shootDirection = finalPosition - position;
      shootStrength = shootDirection.length /
          500;
      shootDirection.normalize();
      shootCallback();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isChoosingDirection) {
      angle = atan2(shootDirection.y, shootDirection.x);
    }
    if (isShooting) {
      position += shootDirection * shootStrength * dt * 500;
      // Reset the player's state when the shot is complete
      if (position.y <= 0) {
        isChoosingDirection = false;
        isShooting = false;
        position = Vector2(game.size.x / 2, game.size.y - 200);
      }
    }
  }
}

class Goalie extends SpriteComponent {
  Goalie({
    required Vector2 position,
    required Sprite sprite,
  }) : super(
    position: position,
    size: Vector2(100, 100),
    sprite: sprite,
  );
}

class ScoreDisplay extends TextComponent {
  ScoreDisplay({
    required Vector2 position,
  }) : super(
    text: 'Score: 0',
    position: position,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 32.0,
        fontFamily: 'Arial',
        color: Color(0xFFFFFFFF),
      ),
    ),
  );

  void updateScore(int newScore) {
    text = 'Score: $newScore';
  }
}
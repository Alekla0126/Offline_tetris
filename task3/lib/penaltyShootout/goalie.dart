import 'package:flame/components.dart';
import 'penaltyGame.dart';
import 'ball.dart';

class Goalie extends SpriteComponent {
  final double moveSpeed;
  final PenaltyGame game;
  bool isBallStopped = false;
  Ball? ball; // Reference to the ball

  Goalie({
    required Vector2 position,
    required Sprite sprite,
    required this.game,
    this.moveSpeed = 200.0,
  }) : super(
    position: position,
    size: Vector2(100, 100),
    sprite: sprite,
  );

  @override
  void update(double dt) {
    super.update(dt);

    final ballPosition = game.player.position;
    final goaliePosition = position;

    // Calculate the direction vector from the goalie to the ball
    final direction = ballPosition - goaliePosition;
    direction.normalize();

    // Calculate the goalie's new position based on the direction and movement speed
    final newPosition = Vector2(ballPosition.x, goaliePosition.y);

    // Ensure the goalie stays within the game bounds
    final gameSize = game.size;
    final goalieSize = size;
    final minX = goalieSize.x / 2;
    final maxX = gameSize.x - goalieSize.x / 2;

    final clampedX = newPosition.x.clamp(minX, maxX).toDouble();

    // Set the goalie's new position
    position = Vector2(clampedX, goaliePosition.y);
  }

  void stopBall() {
    isBallStopped = true;
    game.player.stop();
  }
}
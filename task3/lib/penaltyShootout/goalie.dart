import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'penaltyGame.dart';
import 'ball.dart';

class Goalie extends SpriteComponent with HasCollisionDetection{
  final double moveSpeed;
  final PenaltyGame game;
  bool isBallStopped = false;
  Ball? ball; // Reference to the ball

  Goalie({
    required Vector2 position,
    required Sprite sprite,
    required this.game,
    this.moveSpeed = 100.0, // Adjust the moveSpeed to control the goalie's movement
  }) : super(
    position: position,
    size: Vector2(100, 100),
    sprite: sprite,
  ) {
    // Add the hitbox to your component
    add(RectangleHitbox(size: Vector2(50, 50)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final ballPosition = game.player.position;
    final goaliePosition = position;

    // Calculate the direction vector from the goalie to the ball
    final direction = ballPosition - goaliePosition;
    direction.normalize();

    // Calculate the goalie's new position based on the direction and movement speed
    final movement = direction * (moveSpeed * dt);
    final newPosition = goaliePosition + movement;

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
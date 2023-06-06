import 'package:flame/components.dart';
import 'penaltyGame.dart';
import 'goalie.dart';
import 'dart:math';

class Ball extends SpriteComponent {
  late void Function() shootCallback;
  Vector2 velocity = Vector2.zero();
  bool isChoosingDirection = false;
  late final PenaltyGame game; // Add the game reference
  late Vector2 shootDirection;
  double shootStrength = 0;
  bool isShooting = false;

  Ball({
    required Vector2 position,
    required this.shootCallback,
    required Sprite sprite,
    required this.game, // Pass the game reference
  }) : super(
    position: position,
    size: Vector2.all(100),
    sprite: sprite,
  );

  void stop() {
    velocity.setZero();
  }

  void startChoosingDirection(Vector2 initialPosition) {
    isChoosingDirection = true;
    shootDirection = initialPosition - position;
    shootDirection.normalize();
  }

  void shootPenalty(Vector2 finalPosition) {
    if (!isShooting) {
      isShooting = true;
      shootDirection = finalPosition - position;
      shootStrength = shootDirection.length / 500;
      shootDirection.normalize();
      shootCallback();
    }
  }

  void reset() {
    position = Vector2(size.x / 2, size.y - 200);
    velocity = Vector2.zero();
  }

  bool collidesWithGoalie(Goalie goalie) {
    final ballRect = toRect();
    final goalieRect = goalie.toRect();
    return ballRect.overlaps(goalieRect);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isChoosingDirection) {
      angle = atan2(shootDirection.y, shootDirection.x);
    }
    if (isShooting) {
      position += shootDirection * shootStrength * dt * 500;
      // Calculate the distance from the initial position
      final distance = (position - game.size / 2).length;
      // Calculate the ball's size based on the distance
      const minSize = 20;
      const maxSize = 100;
      const sizeRange = maxSize - minSize;
      final ballSize = minSize + (1 - (distance / (game.size.y / 2))) * sizeRange;
      // Update the ball's size
      size = Vector2.all(ballSize);
      // Reset the player's state when the shot is complete
      if (position.y <= 0) {
        isChoosingDirection = false;
        isShooting = false;
        position = Vector2(game.size.x / 2, game.size.y - 200);
        // Reset the ball size
        size = Vector2.all(minSize.toDouble());
      }
    }
  }
}
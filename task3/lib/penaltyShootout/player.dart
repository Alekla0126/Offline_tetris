import 'package:flame/components.dart';

class Player extends SpriteComponent {
  double speed = 200;

  Player() : super(
    size: Vector2.all(50),
    position: Vector2(50, 250),
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
  }
}
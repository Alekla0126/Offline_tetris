import 'package:flame/components.dart';

class Goalie extends SpriteComponent {
  Goalie() : super(
    size: Vector2.all(50),
    position: Vector2(350, 250),
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('goalie.png');
  }
}
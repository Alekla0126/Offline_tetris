import 'package:flame/components.dart';

class Ball extends SpriteComponent {
  Vector2? speed = Vector2.zero();

  Ball() : super(
    size: Vector2.all(25),
    position: Vector2(100, 250),
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ball.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (speed != null) {
      position += speed! * dt;
    }
  }
}
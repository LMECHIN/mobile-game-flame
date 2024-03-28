import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Obstacle extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  bool rotate;
  Obstacle({
    position,
    size,
    this.rotate = false,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    if (!rotate) {
      final hitboxShape = PolygonHitbox([
        Vector2(0, size.y),
        Vector2(size.x / 2, 0),
        Vector2(size.x, size.y),
      ]);
      add(hitboxShape);
    } else {
      final hitboxShape = PolygonHitbox([
        Vector2(size.x, 0),
        Vector2(size.x / 2, size.y),
        Vector2(0, 0),
      ]);
      add(hitboxShape);
    }
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/Obstacle01.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(264, 264),
        loop: false,
      ),
    );
    // debugMode = true;
    return super.onLoad();
  }
}

import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Obstacle extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  Obstacle({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    final hitboxShape = PolygonHitbox([
      Vector2(0, size.y),
      Vector2(size.x / 2, 0),
      Vector2(size.x, size.y),
    ]);
    add(hitboxShape);
    // debugMode = true;
    return super.onLoad();
  }
}

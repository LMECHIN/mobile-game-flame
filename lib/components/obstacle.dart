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
        ) {
          debugMode = true;
        }

  @override
  FutureOr<void> onLoad() {
    priority = 0;
    print(position);
    add(RectangleHitbox());

    return super.onLoad();
  }

}

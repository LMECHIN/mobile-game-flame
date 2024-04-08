import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Rope extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  Rope({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Sprites/14-TileSets/Texture_Obstacles/rope_obstacle.png'),
      SpriteAnimationData.sequenced(
        amount: 9,
        stepTime: 0.08,
        textureSize: Vector2.all(264),
        loop: true,
      ),
    );

    return super.onLoad();
  }

  void reset() {}
}

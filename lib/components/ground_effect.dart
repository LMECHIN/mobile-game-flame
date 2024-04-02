import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class GroundEffect extends SpriteAnimationComponent
    with HasGameRef<PixelGame> {
  GroundEffect({
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
      game.images.fromCache('Sprites/14-TileSets/ground_walk_effect.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.05,
        textureSize: Vector2.all(264),
        loop: false,
      ),
    );
    return super.onLoad();
  }
  void reset() {}
}

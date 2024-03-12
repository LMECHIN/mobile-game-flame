import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Trail extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  Trail({
    position,
    // size,
  }) : super(
          position: position,
          // size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Trail (264x264).png'),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.01,
        textureSize: Vector2.all(264),
      ),
    );

    return super.onLoad();
  }
}

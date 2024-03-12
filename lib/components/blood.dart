import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Blood extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  Blood({
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
      game.images.fromCache('Checkpoints/Blood (194x194).png'),
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2.all(194),
      ),
    );

    return super.onLoad();
  }
}

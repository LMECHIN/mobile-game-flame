import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Blocks extends SpriteAnimationComponent with HasGameRef<PixelGame> {
    int color;
    bool loop;
    Blocks({
    position,
    size,
    this.color = 2,
    this.loop = false,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/ground_blue_test(fix).png'),
      SpriteAnimationData.sequenced(
        amount: color,
        stepTime: 1,
        textureSize: Vector2(266, 264), // Fix bug texture /!\
        loop: loop,
      ),
    );
    return super.onLoad();
  }

}

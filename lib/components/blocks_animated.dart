import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class BlocksAnimated extends SpriteAnimationComponent
    with HasGameRef<PixelGame> {
  int color;
  bool loop;
  int start;
  int end;
  List<double> speedLoop;
  final String texture;
  BlocksAnimated({
    position,
    size,
    this.color = 2,
    this.loop = false,
    this.start = 0,
    this.end = 1,
    required this.speedLoop,
    required this.texture,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.range(
        start: start,
        end: end,
        amount: color,
        stepTimes: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
    return super.onLoad();
  }

  void reset() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.range(
        start: start,
        end: end,
        amount: color,
        stepTimes: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
  }
}

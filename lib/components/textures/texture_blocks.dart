import 'dart:async';

import 'package:flame/components.dart';
import 'package:game/game_run.dart';

class TextureBlocks extends SpriteAnimationComponent
    with HasGameRef<GameRun> {
  bool hasOn;
  TextureBlocks({
    position,
    size,
    this.hasOn = false,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    if (hasOn) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Sprites/14-TileSets/Texture_Blocks/texture_block.png'),
        SpriteAnimationData.sequenced(
          amount: 9,
          stepTime: 0.05,
          textureSize: Vector2.all(66),
          loop: true,
        ),
      );
    }
    return super.onLoad();
  }
}

import 'dart:async';

import 'package:flame/components.dart';
import 'package:game/game_run.dart';

class GroundEffect extends SpriteAnimationComponent with HasGameRef<GameRun> {
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
        stepTime: 0.02,
        textureSize: Vector2(66, 66),
        loop: false,
      ),
    );
    return super.onLoad();
  }
}

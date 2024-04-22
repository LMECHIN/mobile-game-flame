import 'dart:async';

import 'package:flame/components.dart';
import 'package:game/game_run.dart';
import 'package:game/utils/border_texture.dart';

class BorderBlocks extends SpriteAnimationComponent with HasGameRef<GameRun> {
  int borderIndex;
  List<String> borderTexture = [
    borderUp,
    borderDown,
    borderLeft,
    borderRight,
    borderUpLeft,
    borderUpRight,
    borderDownLeft,
    borderDownRight,
    borderUpDown,
    borderUpDownLeft,
    borderUpDownRight,
    borderLeftRight,
    borderLeftRightUp,
    borderLeftRightDown,
    borderLeftRightUpDown,
  ];

  BorderBlocks({
    position,
    size,
    this.borderIndex = 15,
  }) : super(
          position: position,
          size: size,
        );

  static const int maxIndex = 15;

  @override
  Future<void> onLoad() async {
    priority = -1;
    if (borderIndex != maxIndex) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Sprites/14-TileSets/Borders/${borderTexture[borderIndex]}.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(20, 20),
          loop: false,
        ),
      );
    }
    await super.onLoad();
  }
}

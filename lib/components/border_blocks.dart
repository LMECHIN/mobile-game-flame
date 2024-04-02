import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/utils/border_texture.dart';

class BorderBlocks extends SpriteAnimationComponent with HasGameRef<PixelGame> {
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
          textureSize: Vector2.all(264),
          loop: false,
        ),
      );
    }
    await super.onLoad();
  }

  void reset() {}
}

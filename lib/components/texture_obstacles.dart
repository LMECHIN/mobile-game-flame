import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class TextureObstacles extends SpriteAnimationComponent
    with HasGameRef<PixelGame> {
  bool hasOn;
  String rotate;

  TextureObstacles({
    position,
    size,
    this.hasOn = false,
    this.rotate = "down",
  }) : super(
          position: position,
          size: size,
        );

  List<String> texture = [
    "texture_obstacle_up",
    "texture_obstacle_down",
    "texture_obstacle_left",
    "texture_obstacle_right",
  ];

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    if (hasOn) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Sprites/14-TileSets/Texture_Obstacles/texture_obstacle_$rotate.png'),
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

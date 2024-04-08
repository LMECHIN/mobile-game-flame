import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/texture_obstacles.dart';
import 'package:flutter_application_1/pixel_game.dart';

class ObstacleCircle extends SpriteAnimationComponent
    with HasGameRef<PixelGame> {
  int color;
  double speedLoop;
  bool loop;
  bool hasTextureObstacles;
  Map<String, bool> rotate;
  ObstacleCircle({
    position,
    size,
    this.color = 0,
    this.speedLoop = 1,
    this.loop = false,
    this.hasTextureObstacles = false,
    this.rotate = const {
      "up": false,
      "down": false,
      "left": false,
      "right": false,
    },
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    final hitboxShape = CircleHitbox();
    add(hitboxShape);
    rotate.forEach((key, value) {
      if (value) {
        animation = SpriteAnimation.fromFrameData(
          game.images.fromCache(
              'Sprites/14-TileSets/Obstacles_Circles/obstacles_circles_$key.png'),
          SpriteAnimationData.range(
            start: color,
            end: color,
            amount: 10,
            stepTimes: [speedLoop],
            textureSize: Vector2.all(264),
            loop: loop,
          ),
        );
        final textureObstacles = TextureObstacles(hasOn: hasTextureObstacles, rotate: key);
        add(textureObstacles);
      }
    });
    // debugMode = true;
    return super.onLoad();
  }
}

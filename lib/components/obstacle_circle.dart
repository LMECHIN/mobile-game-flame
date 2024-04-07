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
  ObstacleCircle({
    position,
    size,
    this.color = 0,
    this.speedLoop = 1,
    this.loop = false,
    this.hasTextureObstacles = false,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    final hitboxShape = CircleHitbox();
    add(hitboxShape);
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/obstacles1.png'),
      SpriteAnimationData.range(
        start: color,
        end: color,
        amount: 10,
        stepTimes: [speedLoop],
        textureSize: Vector2.all(264),
        loop: loop,
      ),
    );
        final textureBlocks = TextureObstacles(hasOn: hasTextureObstacles);
    add(textureBlocks);
    // debugMode = true;
    return super.onLoad();
  }
}

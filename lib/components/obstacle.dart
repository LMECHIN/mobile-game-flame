import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/texture_obstacles.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/utils/obstacle_hitbox.dart';

class Obstacle extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  int color;
  double speedLoop;
  bool loop;
  bool hasTextureObstacles;
  Map<String, bool> rotate;
  Obstacle({
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
    Map<String, List<Vector2>> directionPoints = triangleHitbox(size);

    priority = -1;
    rotate.forEach((key, value) {
      if (value) {
        if (directionPoints.containsKey(key)) {
          List<Vector2> points = directionPoints[key]!;
          final hitboxShape = PolygonHitbox(points);
          add(hitboxShape);
        }
        animation = SpriteAnimation.fromFrameData(
          game.images.fromCache(
              'Sprites/14-TileSets/Obstacles_Triangles/obstacles_triangles_$key.png'),
          SpriteAnimationData.range(
            start: color,
            end: color,
            amount: 10,
            stepTimes: [speedLoop],
            textureSize: Vector2.all(66),
            loop: loop,
          ),
        );
        final textureObstacles = TextureObstacles(
          hasOn: hasTextureObstacles,
          rotate: key,
          size: Vector2.all(264),
        );
        add(textureObstacles);
      }
    });
    // debugMode = true;
    return super.onLoad();
  }
}

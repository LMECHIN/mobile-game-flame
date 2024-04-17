import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/texture_obstacles.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/utils/obstacle_hitbox.dart';

class Obstacle extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  int color;
  double speedLoop;
  bool loop;
  bool hasTextureObstacles;
  Map<String, bool> rotate;
  Color bluePaintColor;
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
    this.bluePaintColor = const Color(0xFF0000FF),
  }) : super(
          position: position,
          size: size,
        );
  late Paint bluePaint;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    bluePaint = Paint()..color = bluePaintColor;
    rotate.forEach((key, value) {
      if (value) {
        switch (key) {
          case "up":
            Path path = Path();
            path.moveTo(0, 0);
            path.lineTo(64, 0);
            path.lineTo(32.5, 64);
            path.close();
            canvas.drawPath(path, bluePaint);
            break;
          case "down":
            Path path = Path();
            path.moveTo(0, 64);
            path.lineTo(64, 64);
            path.lineTo(32.5, 0);
            path.close();
            canvas.drawPath(path, bluePaint);
            break;
          case "left":
            Path path = Path();
            path.moveTo(64, 32.5);
            path.lineTo(0, 0);
            path.lineTo(0, 64);
            path.close();
            canvas.drawPath(path, bluePaint);

            break;
          case "right":
            Path path = Path();
            path.moveTo(0, 32.5);
            path.lineTo(64, 0);
            path.lineTo(64, 64);
            path.close();
            canvas.drawPath(path, bluePaint);
            break;
        }
      }
    });
  }

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
              'Sprites/14-TileSets/Borders/obstacle_$key.png'),
          SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(132, 132),
            loop: false,
          ),
        );
        final textureObstacles = TextureObstacles(
          hasOn: hasTextureObstacles,
          rotate: key,
          size: Vector2.all(66),
        );
        add(textureObstacles);
      }
    });
    return super.onLoad();
  }
}

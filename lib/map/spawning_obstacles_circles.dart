import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/obstacle_circle.dart';
import 'package:flutter_application_1/components/player.dart';

void spawningObstaclesCircles(
    ObjectGroup? spawnPointsObstaclesCircles,
    Player player,
    FutureOr<void> Function(Component) add,
    void Function(Component) remove,
    dynamic children,
    List<ObstacleCircle> generatedObstaclesCircles) {
  final double playerX = player.position.x;
  final double playerY = player.position.y;

  if (spawnPointsObstaclesCircles != null) {
    for (final spawnObstacleCircle in spawnPointsObstaclesCircles.objects) {
      final double spawnX = spawnObstacleCircle.x;
      final double spawnY = spawnObstacleCircle.y;
      final double distanceToPlayer =
          (spawnX - playerX).abs() + (spawnY - playerY).abs();

      if (distanceToPlayer < 5000) {
        bool hasObstacleCircle = false;
        for (final child in children) {
          if (child is ObstacleCircle &&
              child.position.x == spawnX &&
              child.position.y == spawnY) {
            hasObstacleCircle = true;
            break;
          }
        }

        if (!hasObstacleCircle) {
          final obstacle = ObstacleCircle(
            position: Vector2(spawnX, spawnY),
            size: Vector2(spawnObstacleCircle.width, spawnObstacleCircle.height),
            color: spawnObstacleCircle.properties.getValue('Color') ?? 0,
            loop: spawnObstacleCircle.properties.getValue('Loop') ?? false,
            speedLoop: spawnObstacleCircle.properties.getValue('Speedloop') ?? 1,
            hasTextureObstacles: spawnObstacleCircle.properties.getValue('TextureObstacle') ?? false
          );
          add(obstacle);
          generatedObstaclesCircles.add(obstacle);
        }
      }
    }
    for (final obstacleCircle in generatedObstaclesCircles) {
      final double distanceToPlayer = (obstacleCircle.position.x - playerX).abs() +
          (obstacleCircle.position.y - playerY).abs();
      if (distanceToPlayer >= 5000) {
        remove(obstacleCircle);
        generatedObstaclesCircles.remove(obstacleCircle);
      }
    }
  }
}

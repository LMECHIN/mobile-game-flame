import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/player.dart';

void spawningObstacles(
    ObjectGroup? spawnPointsObstacles,
    Player player,
    FutureOr<void> Function(Component) add,
    void Function(Component) remove,
    dynamic children,
    List<Obstacle> generatedObstacles) {
  final double playerX = player.position.x;
  final double playerY = player.position.y;

  if (spawnPointsObstacles != null) {
    for (final spawnObstacle in spawnPointsObstacles.objects) {
      final double spawnX = spawnObstacle.x;
      final double spawnY = spawnObstacle.y;
      final double distanceToPlayer =
          (spawnX - playerX).abs() + (spawnY - playerY).abs();

      if (distanceToPlayer < 5000) {
        bool hasObstacle = false;
        for (final child in children) {
          if (child is Obstacle &&
              child.position.x == spawnX &&
              child.position.y == spawnY) {
            hasObstacle = true;
            break;
          }
        }

        if (!hasObstacle) {
          final obstacle = Obstacle(
            position: Vector2(spawnX, spawnY),
            size: Vector2(spawnObstacle.width, spawnObstacle.height),
            color: spawnObstacle.properties.getValue('Color') ?? 0,
            loop: spawnObstacle.properties.getValue('Loop') ?? false,
            speedLoop: spawnObstacle.properties.getValue('Speedloop') ?? 1,
            hasTextureObstacles: spawnObstacle.properties.getValue('TextureObstacle') ?? false,
            rotate:  {
              "up" : spawnObstacle.properties.getValue('Up') ?? false,
              "down" : spawnObstacle.properties.getValue('Down') ?? false,
              "left" : spawnObstacle.properties.getValue('Left') ?? false,
              "right" : spawnObstacle.properties.getValue('Right') ?? false,
            }
          );
          add(obstacle);
          generatedObstacles.add(obstacle);
        }
      }
    }
    for (final obstacle in generatedObstacles) {
      final double distanceToPlayer = (obstacle.position.x - playerX).abs() +
          (obstacle.position.y - playerY).abs();
      if (distanceToPlayer >= 5000) {
        remove(obstacle);
        generatedObstacles.remove(obstacle);
      }
    }
  }
}

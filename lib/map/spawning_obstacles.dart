import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:game/components/blocks.dart';
import 'package:game/components/obstacle.dart';
import 'package:game/components/player.dart';
// import 'package:game/utils/transition.dart';

void spawningObstacles(
  ObjectGroup? spawnPointsObstacles,
  Player player,
  FutureOr<void> Function(Component) add,
  void Function(Component) remove,
  void Function(Color) updateBackgroundColor,
  void Function(Color) updateBackgroundColorBottom,
  dynamic children,
  List<Blocks> generatedBlocks,
  List<Obstacle> generatedObstacles,
) {
  final double playerX = player.position.x;
  List<Obstacle> obstaclesToRemove = [];

  for (final spawnObstacle in spawnPointsObstacles!.objects) {
    final double spawnX = spawnObstacle.x;
    final double distanceToPlayer = (spawnX - playerX).abs();

    if (distanceToPlayer < 800) {
      bool hasObstacle = false;
      for (final child in children) {
        if (child is Obstacle &&
            child.position.x == spawnX &&
            child.position.y == spawnObstacle.y) {
          hasObstacle = true;
          break;
        }
      }

      if (!hasObstacle) {
        final obstacle = Obstacle(
            position: Vector2(spawnX, spawnObstacle.y),
            size: Vector2(spawnObstacle.width, spawnObstacle.height),
            color: spawnObstacle.properties.getValue('Color') ?? 0,
            loop: spawnObstacle.properties.getValue('Loop') ?? false,
            speedLoop: spawnObstacle.properties.getValue('Speedloop') ?? 1,
            hasTextureObstacles:
                spawnObstacle.properties.getValue('TextureObstacle') ?? false,
            rotate: {
              "up": spawnObstacle.properties.getValue('Up') ?? false,
              "down": spawnObstacle.properties.getValue('Down') ?? false,
              "left": spawnObstacle.properties.getValue('Left') ?? false,
              "right": spawnObstacle.properties.getValue('Right') ?? false,
            });
        add(obstacle);
        generatedObstacles.add(obstacle);
      }
    }

    for (final obstacle in generatedObstacles) {
      final double distanceToPlayer = (obstacle.position.x - playerX).abs();
      if (distanceToPlayer >= 800 &&
          !obstacle.isRemoving &&
          obstacle.isMounted) {
        obstaclesToRemove.add(obstacle);
      }
    }

    for (final obstacleToRemove in obstaclesToRemove) {
      remove(obstacleToRemove);
      generatedObstacles.remove(obstacleToRemove);
    }
  }
}

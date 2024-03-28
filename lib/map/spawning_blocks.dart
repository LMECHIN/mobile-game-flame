import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/player.dart';

void spawningBlocks(
    ObjectGroup? spawnPointsBlocks,
    Player player,
    FutureOr<void> Function(Component) add,
    void Function(Component) remove,
    dynamic children,
    List<Blocks> generatedBlocks) {
  final double playerX = player.position.x;
  final double playerY = player.position.y;

  if (spawnPointsBlocks != null) {
    for (final spawnBlock in spawnPointsBlocks.objects) {
      final double spawnX = spawnBlock.x;
      final double spawnY = spawnBlock.y;
      final double distanceToPlayer =
          (spawnX - playerX).abs() + (spawnY - playerY).abs();
      final int time = spawnBlock.properties.getValue('Time') ?? 0;

      if (distanceToPlayer < 5000) {
        bool hasBlock = false;
        for (final child in children) {
          if (child is Blocks &&
              child.position.x == spawnX &&
              child.position.y == spawnY) {
            hasBlock = true;
            break;
          }
        }

        if (!hasBlock) {
          final blocks = Blocks(
            position: Vector2(spawnX, spawnY),
            size: Vector2(spawnBlock.width, spawnBlock.height),
            color: spawnBlock.properties.getValue('Color') ?? 1,
            texture: spawnBlock.properties.getValue('Texture') ??
                'ground_blue_test(fix)',
            groundTexture: spawnBlock.properties.getValue('GroundTexture') ??
                'ground_player',
          );
          add(blocks);
          generatedBlocks.add(blocks);
          if (time != 0) {
            Future.delayed(Duration(seconds: time), () {
              final blocksTime = Blocks(
                position: Vector2(spawnX, spawnY),
                size: Vector2(spawnBlock.width, spawnBlock.height),
                color: spawnBlock.properties.getValue('NextColor') ?? 1,
                texture: spawnBlock.properties.getValue('Texture') ??
                    'ground_blue_test(fix)',
                groundTexture:
                    spawnBlock.properties.getValue('GroundTexture') ??
                        'ground_player',
              );
              add(blocksTime);
              generatedBlocks.add(blocksTime);
            });
          }
        }
      }
    }

    for (final block in generatedBlocks) {
      final double distanceToPlayer = (block.position.x - playerX).abs() +
          (block.position.y - playerY).abs();
      if (distanceToPlayer >= 5000) {
        remove(block);
        generatedBlocks.remove(block);
      }
    }
  }
}

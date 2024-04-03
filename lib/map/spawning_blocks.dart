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

      if (distanceToPlayer < 6000) {
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
            borders: [
              spawnBlock.properties.getValue('BorderUp') ?? false,
              spawnBlock.properties.getValue('BorderDown') ?? false,
              spawnBlock.properties.getValue('BorderLeft') ?? false,
              spawnBlock.properties.getValue('BorderRight') ?? false,
              spawnBlock.properties.getValue('BorderUpLeft') ?? false,
              spawnBlock.properties.getValue('BorderUpRight') ?? false,
              spawnBlock.properties.getValue('BorderDownLeft') ?? false,
              spawnBlock.properties.getValue('BorderDownRight') ?? false,
              spawnBlock.properties.getValue('BorderUpDown') ?? false,
              spawnBlock.properties.getValue('BorderUpDownLeft') ?? false,
              spawnBlock.properties.getValue('BorderUpDownRight') ?? false,
              spawnBlock.properties.getValue('BorderLeftRight') ?? false,
              spawnBlock.properties.getValue('BorderLeftRightUp') ?? false,
              spawnBlock.properties.getValue('BorderLeftRightDown') ?? false,
              spawnBlock.properties.getValue('BorderLeftRightUpDown') ?? false,
            ],
            hasTextureBlocks:
                spawnBlock.properties.getValue('TextureBlock') ?? false,
          );
          add(blocks);
          generatedBlocks.add(blocks);
          if (time != 0) {
            Future.delayed(Duration(seconds: time), () {
              if (blocks.hasChildren &&
                  generatedBlocks.isNotEmpty &&
                  blocks.isMounted) {
                remove(blocks);
                generatedBlocks.remove(blocks);
              }
              final blocksTime = Blocks(
                position: Vector2(spawnX, spawnY),
                size: Vector2(spawnBlock.width, spawnBlock.height),
                color: spawnBlock.properties.getValue('NextColor') ?? 1,
                texture: spawnBlock.properties.getValue('Texture') ??
                    'ground_blue_test(fix)',
                groundTexture:
                    spawnBlock.properties.getValue('GroundTexture') ??
                        'ground_player',
                borders: [
                  spawnBlock.properties.getValue('BorderUp') ?? false,
                  spawnBlock.properties.getValue('BorderDown') ?? false,
                  spawnBlock.properties.getValue('BorderLeft') ?? false,
                  spawnBlock.properties.getValue('BorderRight') ?? false,
                  spawnBlock.properties.getValue('BorderUpLeft') ?? false,
                  spawnBlock.properties.getValue('BorderUpRight') ?? false,
                  spawnBlock.properties.getValue('BorderDownLeft') ?? false,
                  spawnBlock.properties.getValue('BorderDownRight') ?? false,
                  spawnBlock.properties.getValue('BorderUpDown') ?? false,
                  spawnBlock.properties.getValue('BorderUpDownLeft') ?? false,
                  spawnBlock.properties.getValue('BorderUpDownRight') ?? false,
                  spawnBlock.properties.getValue('BorderLeftRight') ?? false,
                  spawnBlock.properties.getValue('BorderLeftRightUp') ?? false,
                  spawnBlock.properties.getValue('BorderLeftRightDown') ??
                      false,
                  spawnBlock.properties.getValue('BorderLeftRightUpDown') ??
                      false,
                ],
                hasTextureBlocks:
                    spawnBlock.properties.getValue('TextureBlock') ?? false,
              );
              add(blocksTime);
              generatedBlocks.add(blocksTime);
            });
          }
        }
      }
    }

    for (final uniqueBlock in generatedBlocks) {
      final double distanceToPlayer = (uniqueBlock.position.x - playerX).abs() +
          (uniqueBlock.position.y - playerY).abs();
      if (distanceToPlayer >= 6000 &&
          !uniqueBlock.isRemoving &&
          generatedBlocks.isNotEmpty &&
          uniqueBlock.isMounted) {
        remove(uniqueBlock);
        generatedBlocks.remove(uniqueBlock);
      }
    }
  }
}

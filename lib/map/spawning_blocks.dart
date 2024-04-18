import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/utils/transition.dart';
// import 'package:flutter_application_1/utils/transition_data.dart';

void spawningBlocks(
  ObjectGroup? spawnPointsBlocks,
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
  const double playerDistanceThreshold = 1000;
  List<Blocks> blocksToRemove = [];
  bool changeColor = true;

  // print(spawnPointsBlocks!.properties.getValue('Transition'));
  for (final spawnBlock in spawnPointsBlocks!.objects) {
    final double spawnX = spawnBlock.x;
    final double distanceToPlayer = (spawnX - playerX).abs();

    if (distanceToPlayer < 1000) {
      bool hasBlock = false;
      for (final child in children) {
        if (child is Blocks &&
            child.position.x == spawnX &&
            child.position.y == spawnBlock.y) {
          hasBlock = true;
          break;
        }
      }

      if (!hasBlock) {
        final blocks = Blocks(
          position: Vector2(spawnX, spawnBlock.y),
          size: Vector2(spawnBlock.width, spawnBlock.height),
          color: spawnBlock.properties.getValue('Color') ?? 1,
          texture: spawnBlock.properties.getValue('Texture') ?? true,
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
          hasTextureCross:
              spawnBlock.properties.getValue('TextureCross') ?? false,
          bluePaintColor: Colors.blue,
        );
        add(blocks);
        generatedBlocks.add(blocks);
      }
    }

    for (final uniqueBlock in generatedBlocks.toList()) {
      final double distanceToPlayer = (uniqueBlock.position.x - playerX).abs();
      if (distanceToPlayer >= playerDistanceThreshold &&
          !uniqueBlock.isRemoving &&
          uniqueBlock.isMounted) {
        remove(uniqueBlock);
        blocksToRemove.remove(uniqueBlock);
      }
    }

    for (final blocksToRemove in blocksToRemove) {
      remove(blocksToRemove);
      generatedBlocks.remove(blocksToRemove);
    }

    if (changeColor) {
      transition(
        distanceToPlayer,
        updateBackgroundColor,
        updateBackgroundColorBottom,
        generatedBlocks,
        generatedObstacles,
        spawnPointsBlocks,
      );
      changeColor = false;
    }
  }
}

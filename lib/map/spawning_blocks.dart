import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/player.dart';

void spawningBlocks(
  ObjectGroup? spawnPointsBlocks,
  Player player,
  FutureOr<void> Function(Component) add,
  void Function(Component) remove,
  dynamic children,
  List<Blocks> generatedBlocks,
  TickerProvider tickerProvider,
) async {
  final double playerX = player.position.x;
  const double playerDistanceThreshold = 1400;
  List<Blocks> blocksToRemove = [];

  double maxDistance =
      1400; // Distance à partir de laquelle la transition commence
  const double minDistance = 200;

  for (final spawnBlock in spawnPointsBlocks!.objects) {
    final double spawnX = spawnBlock.x;
    final double distanceToPlayer = (spawnX - playerX).abs();
    // final int time = spawnBlock.properties.getValue('Time') ?? 0;

    if (distanceToPlayer < 1400) {
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

    if (distanceToPlayer < maxDistance) {
      double colorProgress = 0;
      if (distanceToPlayer > minDistance) {
        colorProgress =
            (distanceToPlayer - minDistance) / (maxDistance - minDistance);
      }

      final newColor = Color.lerp(Colors.blue, Colors.purple, colorProgress);
      if (colorProgress >= 1) {
        for (final block in generatedBlocks) {
          block.bluePaintColor = Colors.purple;
        }
      } else {
        for (final block in generatedBlocks) {
          block.bluePaintColor = newColor!;
        }
      }
    } else {
      for (final block in generatedBlocks) {
        block.bluePaintColor = Colors.purple;
      }
    }
  }
}

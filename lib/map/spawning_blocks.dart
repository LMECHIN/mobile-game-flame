import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/player.dart';

class Tuple6<T1, T2, T3, T4, T5, T6> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;
  final T5 item5;
  final T6 item6;

  Tuple6(
    this.item1,
    this.item2,
    this.item3,
    this.item4,
    this.item5,
    this.item6,
  );
}

void spawningBlocks(
  ObjectGroup? spawnPointsBlocks,
  Player player,
  FutureOr<void> Function(Component) add,
  void Function(Component) remove,
  void Function(Color) updateBackgroundColor,
  void Function(Color) updateBackgroundColorBottom,
  dynamic children,
  List<Blocks> generatedBlocks,
) {
  final double playerX = player.position.x;
  const double playerDistanceThreshold = 1000;
  List<Blocks> blocksToRemove = [];
  bool changeColor = true;

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

    final List<Tuple6<double, double, Color, Color, Color, Color>>
        transitionData = [
      Tuple6(
        3000,
        4000,
        Colors.blue,
        Colors.purple,
        const Color.fromARGB(255, 1, 60, 109),
        const Color.fromARGB(255, 74, 0, 87),
      ),
      Tuple6(
        6000,
        7000,
        Colors.purple,
        Colors.red,
        const Color.fromARGB(255, 74, 0, 87),
        const Color.fromARGB(255, 255, 0, 0),
      ),
    ];

    if (changeColor) {
      double colorProgress = 0;

      for (int i = 0; i < transitionData.length; i++) {
        final transition = transitionData[i];
        final double transitionStart = transition.item1;
        final double transitionEnd = transition.item2;

        if (distanceToPlayer <= transitionStart) {
          colorProgress = 0.0;
          break;
        } else if (distanceToPlayer > transitionStart &&
            distanceToPlayer <= transitionEnd) {
          colorProgress = ((distanceToPlayer - transitionStart) /
                  (transitionEnd - transitionStart))
              .clamp(0.0, 1.0);
          break;
        } else if (distanceToPlayer > transitionEnd) {
          colorProgress = 1.0;
          continue;
        }
      }

      Color newColorBack = Colors.transparent;
      Color newColor = Colors.transparent;

      for (int i = 0; i < transitionData.length; i++) {
        final transition = transitionData[i];
        final double transitionStart = transition.item1;
        final double transitionEnd = transition.item2;
        final Color startColor = transition.item3;
        final Color endColor = transition.item4;
        final Color startColorBack = transition.item5;
        final Color endColorBack = transition.item6;

        if (distanceToPlayer < transitionStart) {
          newColorBack = startColorBack;
          newColor = startColor;
          break;
        } else if (distanceToPlayer >= transitionStart &&
            distanceToPlayer <= transitionEnd) {
          newColorBack =
              Color.lerp(startColorBack, endColorBack, colorProgress)!;
          newColor = Color.lerp(startColor, endColor, colorProgress)!;
          break;
        } else if (distanceToPlayer > transitionEnd) {
          newColorBack = endColorBack;
          newColor = endColor;
        }
      }

      updateBackgroundColor(newColorBack);
      updateBackgroundColorBottom(newColor);

      for (final block in generatedBlocks) {
        block.bluePaintColor = newColor;
      }

      changeColor = false;
    }
  }
}

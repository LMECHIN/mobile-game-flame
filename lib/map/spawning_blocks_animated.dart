import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/blocks_animated.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/widget/animation_properties.dart';

void spawningBlocksAnimated(
    ObjectGroup? spawnPointsBlocksAnimated,
    Player player,
    FutureOr<void> Function(Component) add,
    void Function(Component) remove,
    dynamic children,
    List<BlocksAnimated> generatedBlocksAnimated) {
  final double playerX = player.position.x;

  if (spawnPointsBlocksAnimated != null) {
    for (final spawnBlockAnimated in spawnPointsBlocksAnimated.objects) {
      final double spawnX = spawnBlockAnimated.x;
      final double distanceToPlayer = (spawnX - playerX).abs();
      final int time = spawnBlockAnimated.properties.getValue('Time') ?? 0;
      final bool loop = spawnBlockAnimated.properties.getValue('Loop') ?? true;
      final bool nextLoop =
          spawnBlockAnimated.properties.getValue('NextLoop') ?? true;
      final String textureAnimation =
          spawnBlockAnimated.properties.getValue('Texture') ?? 'down_black';
      final String nextTextureAnimation =
          spawnBlockAnimated.properties.getValue('NextTexture') ??
              'rotate_blue';

      Map<String, dynamic> currentAnimationProps =
          animationProperties[textureAnimation] ?? {};
      Map<String, dynamic> nextAnimationProps =
          animationProperties[nextTextureAnimation] ?? {};

      if (distanceToPlayer < 3000) {
        bool hasBlockAnimated = false;
        for (final child in children) {
          if (child is BlocksAnimated &&
              child.position.x == spawnX &&
              child.position.y == spawnBlockAnimated.y) {
            hasBlockAnimated = true;
            break;
          }
        }
        if (!hasBlockAnimated) {
          final blockAnimated = BlocksAnimated(
            position: Vector2(spawnX, spawnBlockAnimated.y),
            size: Vector2(spawnBlockAnimated.width, spawnBlockAnimated.height),
            color: currentAnimationProps["amount"] ?? 0,
            texture: currentAnimationProps["texture"] ?? "",
            speedLoop: (currentAnimationProps["speedLoop"] as List<num>)
                .map((e) => e.toDouble())
                .toList(),
            loop: loop,
            start: currentAnimationProps["start"] ?? 0,
            end: currentAnimationProps["end"] ?? 0,
          );
          add(blockAnimated);
          generatedBlocksAnimated.add(blockAnimated);
          if (time != 0) {
            Future.delayed(Duration(seconds: time), () {
              if (blockAnimated.hasChildren &&
                  generatedBlocksAnimated.isNotEmpty &&
                  blockAnimated.isMounted) {
                remove(blockAnimated);
                generatedBlocksAnimated.remove(blockAnimated);
              }
              final blocksTime = BlocksAnimated(
                position: Vector2(spawnBlockAnimated.x, spawnBlockAnimated.y),
                size: Vector2(
                    spawnBlockAnimated.width, spawnBlockAnimated.height),
                color: nextAnimationProps["amount"] ?? 0,
                texture: nextAnimationProps["texture"] ?? "",
                speedLoop: (nextAnimationProps["speedLoop"] as List<num>)
                    .map((e) => e.toDouble())
                    .toList(),
                loop: nextLoop,
                start: nextAnimationProps["start"] ?? 0,
                end: nextAnimationProps["end"] ?? 0,
              );
              add(blocksTime);
              generatedBlocksAnimated.add(blocksTime);
            });
          }
        }
      }
    }
    for (final block in generatedBlocksAnimated) {
      final double distanceToPlayer = (block.position.x - playerX).abs();
      if (distanceToPlayer >= 3000 &&
          !block.isRemoving &&
          generatedBlocksAnimated.isNotEmpty &&
          block.isMounted) {
        remove(block);
        generatedBlocksAnimated.remove(block);
      }
    }
  }
}

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
    dynamic children) {
  List<Blocks> generatedBlocks = [];
  final double playerX = player.position.x;
  const double playerDistanceThreshold = 750;

  for (final spawnBlock in spawnPointsBlocks!.objects) {
    final double spawnX = spawnBlock.x;
    final double distanceToPlayer = (spawnX - playerX).abs();
    final int time = spawnBlock.properties.getValue('Time') ?? 0;

    if (distanceToPlayer < playerDistanceThreshold) {
      final Set<Vector2> blockPositions = Set.from(
        children.whereType<Blocks>().map((child) => child.position),
      );

      bool hasBlock = blockPositions.contains(Vector2(spawnX, spawnBlock.y));

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
        );
        add(blocks);
        generatedBlocks.add(blocks);
        if (time != 0) {
          Future.delayed(Duration(seconds: time), () {
            if (blocks.hasChildren &&
                generatedBlocks.contains(blocks) &&
                blocks.isMounted) {
              remove(blocks);
              generatedBlocks.remove(blocks);
            }
          });
        }
      }
    }
  }
  for (final uniqueBlock in generatedBlocks.toList()) {
    final double distanceToPlayer = (uniqueBlock.position.x - playerX).abs();
    if (distanceToPlayer >= playerDistanceThreshold &&
        !uniqueBlock.isRemoving &&
        generatedBlocks.contains(uniqueBlock) &&
        uniqueBlock.isMounted) {
      remove(uniqueBlock);
      generatedBlocks.remove(uniqueBlock);
    }
  }
}

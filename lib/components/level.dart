import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/blocks_animated.dart';
import 'package:flutter_application_1/components/boost_up.dart';
import 'package:flutter_application_1/components/checkpoint.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/particles.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/utils/get_level_data.dart';
import 'package:flutter_application_1/widget/animation_properties.dart';

class Level extends World with HasGameRef<PixelGame> {
  final String? levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  Vector2 startingPosition = Vector2.zero();
  List<CollisionsBlock> collisionsBlock = [];
  late CameraComponent cam;
  late LevelData _levelData;
  late Checkpoint checkpoint;
  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;
  List<Blocks> generatedBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    _levelData = await getLevelData();
    level = await TiledComponent.load("$levelName", Vector2.all(264),
        prefix: 'assets/tiles/');

    add(level);

    _spawningParticles();
    _spawningBlocksAnimated();
    // _spawningBlocks();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    calculateProgress(player.position, checkpoint.position);
    _spawningBlocks();
  }

  void calculateProgress(Vector2 playerPosition, Vector2 checkpointPosition) {
    double distanceToCheckpoint = playerPosition.distanceTo(checkpointPosition);
    double totalDistance = level.width;
    double startOffset = 0.04 * totalDistance;
    double endOffset = 0.03 * totalDistance;

    double levelProgress = 0;

    if ((playerPosition.x - player.startingPosition.x).abs() <= 1.0) {
      levelProgress = 0.0;
    } else if (levelProgress < 100) {
      levelProgress = ((totalDistance - distanceToCheckpoint - endOffset) /
              (totalDistance - startOffset - endOffset)) *
          100;
    }
    if (levelProgress > 100) {
      levelProgress = 100.0;
    }
    if (levelProgress > (_levelData.levelProgress[levelName] ?? 0)) {
      _levelData.selectLevelProgress(levelProgress);
    }
  }

  void _spawningParticles() {
    final spawnPointsParticles =
        level.tileMap.getLayer<ObjectGroup>('SpawnParticles');

    if (spawnPointsParticles != null) {
      for (final spawnParticle in spawnPointsParticles.objects) {
        switch (spawnParticle.class_) {
          case 'Particle':
            break;
          default:
            final particles = Particles(
              position: Vector2(spawnParticle.x, spawnParticle.y),
              size: Vector2(spawnParticle.width / 6, spawnParticle.height / 6),
            );
            particles.widthMap = level.width;
            particles.heightMap = level.height;
            add(particles);
            break;
        }
      }
    }
  }

  void _spawningBlocksAnimated() {
    final spawnPointsBlocksAnimated =
        level.tileMap.getLayer<ObjectGroup>('SpawnBlocksAnimated');
    if (spawnPointsBlocksAnimated != null) {
      for (final spawnBlockAnimated in spawnPointsBlocksAnimated.objects) {
        final int time = spawnBlockAnimated.properties.getValue('Time') ?? 0;
        final bool loop =
            spawnBlockAnimated.properties.getValue('Loop') ?? true;
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

        final blocks = BlocksAnimated(
          position: Vector2(spawnBlockAnimated.x, spawnBlockAnimated.y),
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
        add(blocks);

        Future.delayed(Duration(seconds: time), () {
          remove(blocks);

          final blocksTime = BlocksAnimated(
            position: Vector2(spawnBlockAnimated.x, spawnBlockAnimated.y),
            size: Vector2(spawnBlockAnimated.width, spawnBlockAnimated.height),
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
        });
      }
    }
  }

  void _spawningBlocks() {
    final spawnPointsBlocks =
        level.tileMap.getLayer<ObjectGroup>('SpawnBlocks');

    final double playerX = player.position.x;
    final double playerY = player.position.y;
    if (spawnPointsBlocks != null) {
      for (final spawnBlock in spawnPointsBlocks.objects) {
        final double spawnX = spawnBlock.x;
        final double spawnY = spawnBlock.y;
        final double distanceToPlayer =
            (spawnX - playerX).abs() + (spawnY - playerY).abs();

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

  void _spawningObjects() {
    final spawnPointsPlayer =
        level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsPlayer != null) {
      for (final spawnPoint in spawnPointsPlayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.widthMap = level.width;
            player.heightMap = level.height;
            add(player);
            break;
          case 'Obstacle':
            final obstacle = Obstacle(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(obstacle);
            break;
          case 'BoostsUp':
            final boost = BoostUp(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isBoostUp: true,
            );
            add(boost);
            break;
          case 'Checkpoint':
            checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Plateforms':
            final platform = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionsBlock.add(platform);
            break;
          default:
            final block = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionsBlock.add(block);
            add(block);
        }
      }
    }
    player.collisionsBlock = collisionsBlock;
  }

  void reset() {
    player.collisionsBlock.clear();
    player.collisionsBlock.addAll(collisionsBlock);
  }
}

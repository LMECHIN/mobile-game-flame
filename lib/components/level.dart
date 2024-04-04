import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/blocks_animated.dart';
import 'package:flutter_application_1/components/boost_up.dart';
import 'package:flutter_application_1/components/checkpoint.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/particles.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/map/spawning_blocks.dart';
import 'package:flutter_application_1/map/spawning_blocks_animated.dart';
import 'package:flutter_application_1/map/spawning_obstacles.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/utils/get_level_data.dart';

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
  List<Particles> generatedParticles = [];
  List<Blocks> generatedBlocks = [];
  List<BlocksAnimated> generatedBlocksAnimated = [];
  List<Obstacle> generatedObstacles = [];
  Map<String, DateTime> lastSpawnTimes = {};
  late Color? selectedColor;

  @override
  FutureOr<void> onLoad() async {
    _levelData = await getLevelData();
    level = await TiledComponent.load("$levelName", Vector2.all(264),
        prefix: 'assets/tiles/');

    add(level);

    _spawningBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    calculateProgress(player.position, checkpoint.position);
    _spawningParticles();
    spawningBlocks(
        level.tileMap.getLayer<ObjectGroup>('SpawnBlocks'),
        player,
        (blocks) => add(blocks),
        (blocks) => remove(blocks),
        children,
        generatedBlocks);
    spawningBlocksAnimated(
        level.tileMap.getLayer<ObjectGroup>('SpawnBlocksAnimated'),
        player,
        (blocksAnimated) => add(blocksAnimated),
        (blockAnimated) => remove(blockAnimated),
        children,
        generatedBlocksAnimated);
    spawningObstacles(
        level.tileMap.getLayer<ObjectGroup>('SpawnObstacles'),
        player,
        (obstacle) => add(obstacle),
        (obstacle) => remove(obstacle),
        children,
        generatedObstacles);
  }

  void _spawningBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue('Background');
      if (backgroundColor != null) {
        final colorMap = {
          'dark blue': const Color(0xFF00003C),
          'dark purple': const Color(0xFF770A67),
          'dark red': const Color(0xFF750021),
          'dark green': const Color(0xFF0D7260),
          'pink': const Color(0xFFFF0C89),
          'red': const Color(0xFFFF0C00),
          'yellow': const Color(0xFFFFF600),
          'green': const Color(0xFF00FF55),
          'blue': const Color(0xFF00FFED),
        };
        selectedColor = colorMap[backgroundColor];
        if (selectedColor != null) {
          gameRef.updateBackgroundColor(selectedColor ?? Colors.black);
          // gameRef.setInitColor(selectedColor);
        } else {
          gameRef.updateBackgroundColor(Colors.black);
        }
      }
    }
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

    final double playerX = player.position.x;
    final double playerY = player.position.y;
    if (spawnPointsParticles != null) {
      for (final spawnParticle in spawnPointsParticles.objects) {
        final double spawnX = spawnParticle.x;
        final double spawnY = spawnParticle.y;
        final double distanceToPlayer =
            (spawnX - playerX).abs() + (spawnY - playerY).abs();

        if (distanceToPlayer < 5000) {
          final lastSpawnTime = lastSpawnTimes[spawnParticle.name];
          final currentTime = DateTime.now();
          bool hasParticle = false;
          for (final child in children) {
            if (child is Blocks &&
                child.position.x == spawnX &&
                child.position.y == spawnY) {
              hasParticle = true;
              break;
            }
          }
          if (!hasParticle &&
              (lastSpawnTime == null ||
                  currentTime.difference(lastSpawnTime) >=
                      const Duration(seconds: 1))) {
            final particles = Particles(
              position: Vector2(spawnParticle.x, spawnParticle.y),
              size: Vector2(spawnParticle.width / 6, spawnParticle.height / 6),
            );
            particles.widthMap = level.width;
            particles.heightMap = level.height;
            add(particles);
            generatedParticles.add(particles);
            lastSpawnTimes[spawnParticle.name] = currentTime;
          }
        }
      }
      for (final particle in generatedParticles) {
        final double distanceToPlayer = (particle.position.x - playerX).abs() +
            (particle.position.y - playerY).abs();
        if (distanceToPlayer >= 5000) {
          remove(particle);
          generatedParticles.remove(particle);
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
            generatedObstacles.add(obstacle);
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

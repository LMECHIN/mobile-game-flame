import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:game/components/blocks.dart';
import 'package:game/components/boost_up.dart';
import 'package:game/components/checkpoint.dart';
import 'package:game/utils/collisions_block.dart';
import 'package:game/components/obstacle.dart';
import 'package:game/components/particles.dart';
import 'package:game/components/player.dart';
import 'package:game/components/rope.dart';
import 'package:game/map/spawning_blocks.dart';
import 'package:game/map/spawning_obstacles.dart';
import 'package:game/models/level_data.dart';
import 'package:game/game_run.dart';
import 'package:game/utils/get_level_data.dart';

class Level extends World with HasGameRef<GameRun> {
  final String? levelName;
  final Player player;

  Level({
    required this.levelName,
    required this.player,
  });

  late TiledComponent level;
  late LevelData _levelData;
  late Checkpoint checkpoint;

  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;

  Vector2 startingPosition = Vector2.zero();

  List<Particles> generatedParticles = [];
  List<CollisionsBlock> collisionsBlock = [];
  List<Blocks> generatedBlocks = [];
  List<Obstacle> generatedObstacles = [];

  Map<String, DateTime> lastSpawnTimes = {};

  @override
  FutureOr<void> onLoad() async {
    _levelData = await getLevelData();
    level = await TiledComponent.load("$levelName", Vector2.all(16),
        prefix: 'assets/tiles/');

    add(level);
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    calculateProgress(player.position, checkpoint.position);
    _spawningRopes();
    _spawningParticles();
    spawningBlocks(
      level.tileMap.getLayer<ObjectGroup>('SpawnBlocks'),
      player,
      add,
      remove,
      gameRef.updateBackgroundColor,
      gameRef.updateBackgroundColorBottom,
      children,
      generatedBlocks,
      generatedObstacles,
    );
    spawningObstacles(
      level.tileMap.getLayer<ObjectGroup>('SpawnObstacles'),
      player,
      add,
      remove,
      gameRef.updateBackgroundColor,
      gameRef.updateBackgroundColorBottom,
      children,
      generatedBlocks,
      generatedObstacles,
    );
  }

  void calculateProgress(Vector2 playerPosition, Vector2 checkpointPosition) {
    double distanceToCheckpoint = playerPosition.distanceTo(checkpointPosition);
    double totalDistance = level.width;
    double startOffset = 0.01 * totalDistance;
    double levelProgress = 0;

    if ((playerPosition.x - player.startingPosition.x).abs() <= 1.0) {
      levelProgress = 0.0;
    } else if (levelProgress < 100) {
      levelProgress = ((totalDistance - distanceToCheckpoint) /
              (totalDistance - startOffset)) *
          100;
    }

    if (levelProgress > 100) {
      levelProgress = 100.0;
    }

    if (levelProgress > (_levelData.levelProgress[levelName] ?? 0)) {
      _levelData.selectLevelProgress(levelProgress);
    }
  }

  void _spawningRopes() {
    List<Rope> generatedRopes = [];
    final spawnPointsRopes = level.tileMap.getLayer<ObjectGroup>('SpawnRopes');

    final double playerX = player.position.x;
    final double playerY = player.position.y;
    if (spawnPointsRopes != null) {
      for (final spawnRope in spawnPointsRopes.objects) {
        final double spawnX = spawnRope.x;
        final double spawnY = spawnRope.y;
        final double distanceToPlayer =
            (spawnX - playerX).abs() + (spawnY - playerY).abs();

        if (distanceToPlayer < 5000) {
          bool hasRope = false;
          for (final child in children) {
            if (child is Rope &&
                child.position.x == spawnX &&
                child.position.y == spawnY) {
              hasRope = true;
              break;
            }
          }
          if (!hasRope) {
            final ropes = Rope(
              position: Vector2(spawnRope.x, spawnRope.y),
              size: Vector2(spawnRope.width, spawnRope.height),
            );
            add(ropes);
            generatedRopes.add(ropes);
          }
        }
      }
      for (final rope in generatedRopes) {
        final double distanceToPlayer = (rope.position.x - playerX).abs() +
            (rope.position.y - playerY).abs();
        if (distanceToPlayer >= 5000) {
          remove(rope);
          generatedRopes.remove(rope);
        }
      }
    }
  }

  void _spawningParticles() {
    final double playerX = player.position.x;
    final double playerY = player.position.y;
    final spawnPointsParticles =
        level.tileMap.getLayer<ObjectGroup>('SpawnParticles');

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
            player.size = Vector2(spawnPoint.width, spawnPoint.height);
            player.widthMap = level.width;
            player.heightMap = level.height;
            add(player);
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
            break;
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'EndGame':
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
            break;
        }
      }
    }
    player.collisionsBlock = collisionsBlock;
  }
}

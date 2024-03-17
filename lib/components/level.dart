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
import 'package:flutter_application_1/pixel_game.dart';

class Level extends World with HasGameRef<PixelGame> {
  final String? levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  Vector2 startingPosition = Vector2.zero();
  List<CollisionsBlock> collisionsBlock = [];
  late CameraComponent cam;
  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(264),
        prefix: 'assets/tiles/');

    add(level);

    _spawningParticles();
    _spawningBlocks();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
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
              size: Vector2(spawnParticle.width / 8, spawnParticle.height / 8),
            );
            particles.widthMap = level.width;
            particles.heightMap = level.height;
            add(particles);
            break;
        }
      }
    }
  }

  void _spawningBlocks() {
    final spawnPointsBlocks =
        level.tileMap.getLayer<ObjectGroup>('SpawnBlocks');

    if (spawnPointsBlocks != null) {
      for (final spawnBlock in spawnPointsBlocks.objects) {
        final int time = spawnBlock.properties.getValue('Time') ?? 0;
        final bool loop = spawnBlock.properties.getValue('Loop') ?? false;
        final speedLoop = spawnBlock.properties.getValue('SpeedLoop') ?? 1;
        final int color = spawnBlock.properties.getValue('Color') ?? 1;
        final int nextColor = spawnBlock.properties.getValue('NextColor') ?? 1;
        final String texture = spawnBlock.properties.getValue('Texture') ??
            'ground_blue_test(fix)';
        final String textureAnimation =
            spawnBlock.properties.getValue('TextureAnim') ?? 'ground_rotate_02';
        switch (spawnBlock.class_) {
          case 'Block-up':
            final blocksBlack = Blocks(
              position: Vector2(spawnBlock.x, spawnBlock.y),
              size: Vector2(spawnBlock.width, spawnBlock.height),
              color: nextColor,
              texture: texture,
            );
            add(blocksBlack);
            if (time != 0) {
              Future.delayed(Duration(seconds: time), () {
                startingPosition = Vector2(spawnBlock.x, spawnBlock.y);
                final blockUp = Blocks(
                  position: Vector2(spawnBlock.x, 0),
                  size: Vector2(spawnBlock.width, spawnBlock.height),
                  color: color,
                  texture: texture,
                  loop: true,
                  speedLoop: speedLoop.toDouble(),
                );
                add(blockUp);
                // blocksList.add(blockUp);
                // remove(blockUp);
                // blocksList.remove(blockUp);
              });
            }
            break;
          case 'Block-corner-up-left':
            final blocksBlack = Blocks(
              position: Vector2(spawnBlock.x, spawnBlock.y),
              size: Vector2(spawnBlock.width, spawnBlock.height),
              color: color,
              texture: 'ground_blue_test(fix)1',
            );
            add(blocksBlack);
            Future.delayed(Duration(seconds: time), () {
              remove(blocksBlack);
              final blocksBlue = Blocks(
                position: Vector2(spawnBlock.x, spawnBlock.y),
                size: Vector2(spawnBlock.width, spawnBlock.height),
                color: nextColor,
                texture: 'ground_blue_test(fix)1',
              );
              add(blocksBlue);
            });
            break;
          case 'Block-rotate-01':
            final blocksBlack = BlocksAnimated(
              position: Vector2(spawnBlock.x, spawnBlock.y),
              size: Vector2(spawnBlock.width, spawnBlock.height),
              color: color,
              texture: textureAnimation,
              speedLoop: [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
              loop: loop,
              start: 0,
              end: 6,
            );
            add(blocksBlack);
            Future.delayed(Duration(seconds: time), () {
              remove(blocksBlack);
              final blocksBlue = BlocksAnimated(
                position: Vector2(spawnBlock.x, spawnBlock.y),
                size: Vector2(spawnBlock.width, spawnBlock.height),
                color: color,
                texture: textureAnimation,
                speedLoop: [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
                loop: loop,
                start: 7,
                end: 13,
              );
              add(blocksBlue);
            });
            break;
          case 'Block-bounce-01':
            final blocksBlack = BlocksAnimated(
              position: Vector2(spawnBlock.x, spawnBlock.y),
              size: Vector2(spawnBlock.width, spawnBlock.height),
              color: color,
              texture: 'ground_bounce_01',
              speedLoop: [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
              loop: loop,
              start: 0,
              end: 10,
            );
            add(blocksBlack);
            // Future.delayed(Duration(seconds: time), () {
            //   remove(blocksBlack);
            //   final blocksBlue = BlocksAnimated(
            //     position: Vector2(spawnBlock.x, spawnBlock.y),
            //     size: Vector2(spawnBlock.width, spawnBlock.height),
            //     color: color,
            //     texture: 'ground_rotate_02',
            //     speedLoop: [1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
            //     loop: loop,
            //     start: 7,
            //     end: 13,
            //   );
            //   add(blocksBlue);
            // });
            break;
          default:
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
            final checkpoint = Checkpoint(
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
}

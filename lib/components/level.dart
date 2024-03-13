import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/background_tile.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/boost_up.dart';
import 'package:flutter_application_1/components/checkpoint.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Level extends World with HasGameRef<PixelGame> {
  final String? levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionsBlock> collisionsBlock = [];
  late CameraComponent cam;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(264),
        prefix: 'assets/tiles/');

    add(level);

    _changeColorBlocks();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // print(player.hasSlide);
    super.update(dt);
  }

  void _changeColorBlocks() {
    final backgroundLayer = level.tileMap.getLayer('Blocks');

    if (backgroundLayer != null && backgroundLayer is TileLayer) {
      const tileSize = 264;
      final groundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final frame = backgroundLayer.properties.getValue('Frame');
      final mapWidth = backgroundLayer.width;
      final mapHeight = backgroundLayer.height;
      final tileData = backgroundLayer.data!;
      final tilesToAdd = <BackgroundTile>[];
      final lightToAdd = <BackgroundTile>[];

      for (int y = 0; y < mapHeight; y++) {
        for (int x = 0; x < mapWidth; x++) {
          final tileIndex = tileData[y * mapWidth + x];

          if (tileIndex == 2) {
            final position =
                Vector2((x * tileSize).toDouble(), (y * tileSize).toDouble());
            final back = BackgroundTile(
              color: groundColor,
              position: position,
            );
            final light = BackgroundTile(
              color: 'neon/neon_effect_29',
              position: position,
            );
            tilesToAdd.add(back);
            lightToAdd.add(light);
          }
        }
      }

      Future.delayed(const Duration(seconds: 5), () {
        for (int i = 0; i < tilesToAdd.length; i++) {
          final tile = tilesToAdd[i];
          final light = lightToAdd[i];
          Future.delayed(Duration(milliseconds: frame * i), () {
            add(tile);
            add(light);
          });
        }
      });
    }
  }

  void _spawningObjects() {
    final spawnPointsPlayer =
        level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsPlayer != null) {
      for (final spawnPoint in spawnPointsPlayer.objects) {
        // switch (spawnPoint.)
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
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
          case 'Blocks':
            final blocksBlack = Blocks(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              color: 1,
            );
            add(blocksBlack);
          Future.delayed(const Duration(seconds: 5), () {
            final blocksBlue = Blocks(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              color: 2,
            );
            add(blocksBlue);
          });
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

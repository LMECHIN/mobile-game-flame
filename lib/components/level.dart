import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_application_1/components/background_tile.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Level extends World with HasGameRef<PixelGame> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionsBlock> collisionsBlock = [];
  late CameraComponent cam;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(229));

    add(level);

    // _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    const tileSize = 264;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesx = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesx; x++) {
          final backgroundFile = BackgroundTile(
            color: backgroundColor ?? 'Grayy',
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );
          add(backgroundFile);
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
            add(player);
            break;
          case 'Checkpoint':
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

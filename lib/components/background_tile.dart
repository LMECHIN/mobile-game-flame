import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelGame> {
  final String color;
  BackgroundTile({
    this.color = 'Gray',
    position,
  }) : super(
          position: position,
        );

  // final double scrollSpeed = 0.4;

  @override
  FutureOr<void> onLoad() {
    priority = 0;
    size = Vector2.all(64);
    sprite = Sprite(game.images.fromCache('Sprites/14-TileSets/$color.png'));
    return super.onLoad();
  }

  // @override
  // void update(double dt) {
  //   position.y += scrollSpeed;
  //   double tileSize = 64;
  //   int scrollHeight = (game.size.y / tileSize).floor();

  //   if (position.y > scrollHeight * tileSize) position.y = -tileSize;

  //   super.update(dt);
  // }
}

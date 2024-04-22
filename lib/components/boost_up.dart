import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class BoostUp extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  bool isPlatform;
  bool isBoostUp;

  BoostUp({
    position,
    size,
    this.isPlatform = false,
    this.isBoostUp = false,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    final hitboxShape = RectangleHitbox();
    add(hitboxShape);

    return super.onLoad();
  }
}

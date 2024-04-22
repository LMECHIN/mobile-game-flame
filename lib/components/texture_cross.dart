import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class TextureCross extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  bool hasOn;
  TextureCross({
    position,
    size,
    this.hasOn = false,
  }) : super(
          position: position,
          size: size,
        );

  bool hasSlide = false;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    if (hasOn) {
      final hitboxShape = RectangleHitbox();
      add(hitboxShape);

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Sprites/14-TileSets/Texture_Blocks/cross.png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.2,
          textureSize: Vector2.all(66),
          loop: true,
        ),
      );
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (hasOn) {
      if (game.player.hasSlide) {
        hasSlide = true;
        Future.delayed(const Duration(milliseconds: 80), () {
          hasSlide = false;
        });
      }
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (hasOn) {
      if (other is Player) {
        if (!hasSlide) {
          other.respawn();
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/components/player.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  Checkpoint({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(18, 56),
      size: Vector2(12, 8),
      collisionType: CollisionType.passive,
    ));

    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Checkpoints/Checkpoint (No Flag)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Checkpoints/Checkpoint (Flag Out)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    await animationTicker?.completed;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Checkpoints/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
  }
}

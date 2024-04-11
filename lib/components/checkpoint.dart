import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/overlays/end_game.dart';
import 'package:flutter_application_1/overlays/pause_button.dart';
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
  Color color = const Color.fromARGB(255, 0, 0, 0);

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    final hitboxShape = PolygonHitbox([
      Vector2(size.x / 3, size.y),
      Vector2(size.x / 2, 0),
      Vector2(size.x / 2, 0),
    ]);
    add(hitboxShape);
    // debugMode = true;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Checkpoint (No Flag)(264x264).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(66),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
      // _updatePlayerColor(const Color.fromARGB(255, 11, 3, 55));
      other.hasDie = true;
      other.current = PlayerState.idle;
      game.overlays.remove(PauseButton.id);
      game.overlays.add(EndGame.id);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _updatePlayerColor(Color newColor) {
    color = newColor;
    gameRef.updateBackgroundColor(newColor);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Checkpoint (Flag Out)(264x264).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(66),
        loop: false,
      ),
    );

    await animationTicker?.completed;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Checkpoints/Checkpoint (Flag Idle)(264x264).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(66),
      ),
    );
  }
}

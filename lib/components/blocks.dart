import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Blocks extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  int color;
  double speedLoop;
  bool loop;
  final String texture;
  Blocks({
    position,
    size,
    this.color = 2,
    this.speedLoop = 1,
    this.loop = false,
    required this.texture,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    final hitboxShape = RectangleHitbox(
      angle: -0.1,
    );
    add(hitboxShape);

    // debugMode = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.sequenced(
        amount: color,
        stepTime: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedBlock();
      // _updatePlayerColor(const Color.fromARGB(255, 11, 3, 55));
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedBlock() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/ground_player.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.05,
        textureSize: Vector2.all(264),
        loop: false,
      ),
    );

    await animationTicker?.completed;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.sequenced(
        amount: color,
        stepTime: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
  }

  void reset() {
  }

}

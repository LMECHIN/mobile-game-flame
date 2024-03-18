import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class BlocksAnimated extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  int color;
  bool loop;
  int start;
  int end;
  List<double> speedLoop;
  final String texture;
  BlocksAnimated({
    position,
    size,
    this.color = 2,
    this.loop = false,
    this.start = 0,
    this.end = 1,
    required this.speedLoop,
    required this.texture,
  }) : super(
          position: position,
          size: size,
        );

  bool hasSlide = false;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    final hitboxShape = RectangleHitbox(
      // size: Vector2(size.x, size.y),
      // position: Vector2(size.x - (size.x + 20), size.y / 10),
    );
    add(hitboxShape);

    // debugMode = true;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.range(
        start: start,
        end: end,
        amount: color,
        stepTimes: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.player.hasSlide) {
      hasSlide = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        hasSlide = false;
      });
    }
    super.update(dt);
  }

  @override
  void onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (hasSlide) {
        other.moveSpeed = 800;
        removeFromParent();
      } else {
        other.respawn();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void reset() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/$texture.png'),
      SpriteAnimationData.range(
        start: start,
        end: end,
        amount: color,
        stepTimes: speedLoop,
        textureSize: Vector2(264, 264),
        loop: loop,
      ),
    );
  }
}

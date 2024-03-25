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
  bool _isTransitioning = false;
  double transitionDuration = 0.5;
  double _transitionTimer = 0;

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

  @override
  void update(double dt) {
    super.update(dt);

    if (_isTransitioning) {
      _transitionTimer += dt;
      if (_transitionTimer >= transitionDuration) {
        _isTransitioning = false;
        _transitionTimer = 0;
        _restoreOriginalAnimation();
      }
    }
  }

  void _reachedBlock() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/ground_player.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.05,
        textureSize: Vector2.all(264),
        loop: false,
      ),
    );
    _isTransitioning = true;
  }

  void _restoreOriginalAnimation() {
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

  void reset() {}
}

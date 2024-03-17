import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Particles extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  static const double minSpeed = 10;
  static const double maxSpeed = 300;

  late double speed;
  late Vector2 direction;

  Particles({
    Vector2? position,
    Vector2? size,
  }) : super(
          position: position,
          size: size,
        ) {
    speed = minSpeed + (maxSpeed - minSpeed) * Random().nextDouble();
    final randomAngle = Random().nextDouble() * 2 * pi;
    direction = Vector2(cos(randomAngle), sin(randomAngle));
  }
  double widthMap = 0;
  double heightMap = 0;
  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;

  @override
  void onLoad() {
    priority = -1;

    final hitboxShape = CircleHitbox();

    add(hitboxShape);
    // debugMode = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/particle.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(264),
        loop: false,
      ),
    );
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      position.add(direction * speed * fixedDeltaTime);

      if (position.x < 0) {
        position.x = 0;
        direction.x *= -1;
      } else if (position.x > widthMap - size.x) {
        position.x = widthMap - size.x;
        direction.x *= -1;
      }

      if (position.y < 0) {
        position.y = 0;
        direction.y *= -1;
      } else if (position.y > heightMap - size.y) {
        position.y = heightMap - size.y;
        direction.y *= -1;
      }
      accumulatedTime -= fixedDeltaTime;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      removeFromParent();
      // _updatePlayerColor(const Color.fromARGB(255, 11, 3, 55));
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

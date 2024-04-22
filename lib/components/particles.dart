import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/components/player.dart';
import 'package:game/game_run.dart';

class Particles extends SpriteAnimationComponent
    with HasGameRef<GameRun>, CollisionCallbacks {
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
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/particle.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.025,
        textureSize: Vector2.all(264),
        loop: true,
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
      position.x += 5000;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

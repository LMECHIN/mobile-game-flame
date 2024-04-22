import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/game_run.dart';

class BoostUp extends SpriteAnimationComponent with HasGameRef<GameRun> {
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

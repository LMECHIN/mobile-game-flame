import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_application_1/pixel_game.dart';

class ButtonJump extends PositionComponent
    with HasGameRef<PixelGame>, TapCallbacks {
  ButtonJump();

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    position = Vector2(0, 0);
    size = game.size;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}

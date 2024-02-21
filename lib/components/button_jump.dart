import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_application_1/pixel_game.dart';

class ButtonJump extends SpriteComponent with HasGameRef<PixelGame>, TapCallbacks {
  ButtonJump();
  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    sprite = Sprite(game.images.fromCache("HUD/JumpButton.png"));
    position = Vector2(
      game.size.x - buttonSize - margin,
      game.size.y - buttonSize - margin,
    );

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

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pixel_game.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, KeyboardHandler {
  String character;
  String sizeCharacter;
  Vector2 textureSize;
  Player({
    this.character = '01-King Human',
    this.sizeCharacter = '78x58',
    Vector2? textureSize,
    super.position,
  }) : textureSize = textureSize ?? Vector2(78, 58);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyQ) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
        "Sprites/$character/Idle ($sizeCharacter).png", 11, textureSize);

    runningAnimation = _spriteAnimation(
        "Sprites/$character/Run ($sizeCharacter).png", 8, textureSize);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
      String sprite, int amount, Vector2 textureSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(sprite),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    // if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }
}

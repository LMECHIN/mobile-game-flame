import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pixel_game.dart';

enum PlayerState { idle, running }

enum PlayerDirection { left, right, none }

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

  PlayerDirection playerDirection = PlayerDirection.none;
  double movementSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyQ) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }

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

  void _updatePlayerMovement(double dt) {
    double direX = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        direX -= movementSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        direX += movementSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
      default:
    }

    velocity = Vector2(direX, 0.0);
    position += velocity * dt;
  }
}

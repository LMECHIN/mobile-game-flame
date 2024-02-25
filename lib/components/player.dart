import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/player_hitbox.dart';
import 'package:flutter_application_1/components/utils.dart';
import 'package:flutter_application_1/pixel_game.dart';

enum PlayerState { idle, running, jumping, falling, sliding }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, KeyboardHandler {
  String character;
  String sizeCharacter;
  Vector2 textureSize;
  Player({
    this.character = '01-King Human',
    this.sizeCharacter = '2048x2048',
    Vector2? textureSize,
    super.position,
  }) : textureSize = textureSize ?? Vector2(2048, 2048);

  final double stepTime = 0.1;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation slidingAnimation;

  final double _gravity = 5;
  final double _jumpForce = 1800;
  final double _terminalVelocity = 2000;
  double scaleFactor = 0.3;
  double horizontalMovement = 0;
  double moveSpeed = 800;
  double normalMoveSpeed = 800;
  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;

  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasSlide = false;

  List<CollisionsBlock> collisionsBlock = [];
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 300,
    offsetY: 475,
    width: 65,
    height: 65,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    scale = Vector2(scaleFactor, scaleFactor);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      _updatePlayerState();
      _updatePlayerMovement(fixedDeltaTime);
      _checkHorizontalCollisions();
      _applyGravity(fixedDeltaTime);
      _checkVerticalCollisions();

      accumulatedTime -= fixedDeltaTime;
    }


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

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      hasSlide = true;
    } else {
      hasSlide = false;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
        "Sprites/$character/Idle ($sizeCharacter).png", 6, textureSize);

    runningAnimation = _spriteAnimation(
        "Sprites/$character/Run ($sizeCharacter).png", 8, textureSize);

    jumpingAnimation = _spriteAnimation(
        "Sprites/$character/Jump ($sizeCharacter).png", 5, textureSize);

    fallingAnimation = _spriteAnimation(
        "Sprites/$character/Fall ($sizeCharacter).png", 4, textureSize);

    slidingAnimation = _spriteAnimation(
        "Sprites/$character/Slide ($sizeCharacter).png", 5, textureSize);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.sliding: slidingAnimation,
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

    // if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.sliding;
    if (moveSpeed > 800) {
      playerState = PlayerState.sliding;
    } else if ((velocity.x > 0 || velocity.x < 0) && !hasSlide) {
      hasSlide = false;
      playerState = PlayerState.running;
    }
    if (moveSpeed > 800) {
      playerState = PlayerState.sliding;
    } else if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    if (moveSpeed > 800) {
      playerState = PlayerState.sliding;
    } else if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playJump(dt);
    if (hasSlide) {
      _playSlide();
    }

    // if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _playSlide() {
    normalMoveSpeed = moveSpeed;
    moveSpeed = 1000;
    Future.delayed(const Duration(milliseconds: 500), () {
      moveSpeed = 800;
    });
    hasSlide = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionsBlock) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionsBlock) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
}

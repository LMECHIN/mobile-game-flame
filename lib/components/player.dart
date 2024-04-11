import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/boost_up.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/obstacle_circle.dart';
import 'package:flutter_application_1/components/player_hitbox.dart';
import 'package:flutter_application_1/components/trail.dart';
import 'package:flutter_application_1/components/utils.dart';
import 'package:flutter_application_1/pixel_game.dart';

enum PlayerState { idle, running, jumping, falling, sliding, death, appearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, KeyboardHandler, CollisionCallbacks {
  String? character;
  String sizeCharacter;
  Vector2 textureSize;
  Player({
    this.character,
    this.sizeCharacter = '2048x2048',
    Vector2? textureSize,
    super.position,
    super.size,
  }) : textureSize = textureSize ?? Vector2(512, 512);

  // final double stepTime = 0.1;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation slidingAnimation;
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation appearingAnimation;

  bool isLeftKeyPressed = false;
  bool isRightKeyPressed = false;

  Color color = const Color.fromARGB(255, 0, 0, 0);
  final double _gravity = 3.5;
  final double _jumpForce = 700;
  final double _terminalVelocity = 1150;
  double scaleFactor = 2.4;
  double widthMap = 0;
  double heightMap = 0;
  double horizontalMovement = 0;
  double moveSpeed = 300;
  double normalMoveSpeed = 300;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double fixedDeltaTime = 0.08 / 60;
  double accumulatedTime = 0;
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasSlide = false;
  bool hasDie = false;
  late Trail trail;
  int fixCam = 0;
  late double _dt;
  bool delayExpired = false;

  List<CollisionsBlock> collisionsBlock = [];
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 66,
    offsetY: 92,
    width: 20,
    height: 40,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y - 20);
    scale = Vector2(scaleFactor, scaleFactor);

    Vector2 sizeHitbox = Vector2(size.x / 4.5, size.y / 3);
    double adjustementX = size.x / widthMap;
    double adjustementY = size.y / heightMap;

    Vector2 positionHitbox = Vector2(
      ((position.x * adjustementX) + (size.x * 0.25)) -
          ((sizeHitbox.x / 2) * (adjustementX - 1)),
      position.y * adjustementY -
          (size.y * 0.25) -
          (sizeHitbox.y / 2) +
          (sizeHitbox.y * (adjustementY + 0.15)),
    );

    add(RectangleHitbox(position: positionHitbox, size: sizeHitbox));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    _dt = dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!hasDie) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    // horizontalMovement = 1;

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyQ) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // if (isLeftKeyPressed) {
    //   pressKey = true;
    // }
    // if (isRightKeyPressed) {
    //   pressKey = false;
    // }
    // horizontalMovement += isLeftKeyPressed ? -1 : 0;
    // horizontalMovement += isRightKeyPressed ? 1 : 0;
    horizontalMovement += 1;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      hasSlide = true;
    } else {
      hasSlide = false;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    accumulatedTime += _dt;
    if (other is Obstacle || other is ObstacleCircle) {
      respawn();
    }
    if (other is BoostUp) {
      while (accumulatedTime >= fixedDeltaTime) {
        _playJump(fixedDeltaTime);
        _playSlide(fixedDeltaTime);
        accumulatedTime -= fixedDeltaTime;
        break;
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Idle ($sizeCharacter).png", 6, textureSize, 0.15);

    runningAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Run ($sizeCharacter).png", 8, textureSize, 0.08);

    jumpingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Jump ($sizeCharacter).png", 5, textureSize, 0.2);

    fallingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Fall ($sizeCharacter).png", 4, textureSize, 0.1);

    slidingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Slide ($sizeCharacter).png", 5, textureSize, 0.06);

    deathAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Death ($sizeCharacter).png", 8, textureSize, 0.1)
      ..loop = false;

    appearingAnimation = _reanimationSpriteAnimation(
        "Sprites/Skins/$character/Appearing ($sizeCharacter).png",
        3,
        textureSize);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.sliding: slidingAnimation,
      PlayerState.death: deathAnimation,
      PlayerState.appearing: appearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(
      String sprite, int amount, Vector2 textureSize, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(sprite),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  SpriteAnimation _reanimationSpriteAnimation(
      String sprite, int amount, Vector2 textureSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(sprite),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: textureSize,
        loop: false,
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

    if (moveSpeed > 300) {
      playerState = PlayerState.sliding;
    } else if ((velocity.x > 0 || velocity.x < 0) && !hasSlide) {
      hasSlide = false;
      playerState = PlayerState.running;
    }
    if (moveSpeed > 300) {
      playerState = PlayerState.sliding;
    } else if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    if (moveSpeed > 300) {
      playerState = PlayerState.sliding;
    } else if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playJump(dt);
    }
    if (hasSlide) {
      // _playTrail();
      _playSlide(dt);
    }

    if (delayExpired) {
      moveSpeed = 300;
      hasSlide = false;
    }
    // if (velocity.y > _gravity) isOnGround = false; // optional
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerColor(Color newColor) {
    color = newColor;
    gameRef.updateBackgroundColor(newColor);
  }

  void _playJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _playSlide(double dt) {
    moveSpeed = (400000 * dt) / 0.42;
    delayExpired = false;
    _startDelay();
  }

  void _startDelay() {
    Future.delayed(const Duration(milliseconds: 50), () {
      delayExpired = true;
    });
  }

  void _playTrail() {
    add(trail);
    Future.delayed(const Duration(milliseconds: 100), () {
      remove(trail);
    });
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionsBlock) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            respawn();
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            respawn();
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

  void respawn() async {
    const canMoveDuration = Duration(milliseconds: 400);
    hasDie = true;
    hasJumped = false;
    current = PlayerState.death;
    Future.delayed(
        canMoveDuration,
        () => {
              if (gameRef.createLevel.selectedColor != null)
                {
                  _updatePlayerColor(
                      gameRef.createLevel.selectedColor ?? Colors.black)
                }
              else
                {_updatePlayerColor(Colors.black)}
              // remove(blood),
            });
    // add(blood);
    _updatePlayerColor(const Color.fromARGB(255, 250, 250, 250));
    await animationTicker?.completed;
    animationTicker?.reset();

    if (velocity.x < 0 && scale.x < 0) {
      position = Vector2(startingPosition.x + 660, startingPosition.y - 60);
    } else {
      position = Vector2(startingPosition.x, startingPosition.y - 60);
    }

    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    if (velocity.x < 0 && scale.x < 0) {
      position = Vector2(startingPosition.x + 660, startingPosition.y - 60);
    } else {
      position = Vector2(startingPosition.x, startingPosition.y - 60);
    }
    Future.delayed(
        canMoveDuration,
        () => {
              hasDie = false,
            });
  }

  void reset() {
    hasDie = false;
    position = Vector2(startingPosition.x, startingPosition.y - 60);
    current = PlayerState.idle;
  }
}

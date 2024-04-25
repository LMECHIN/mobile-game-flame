import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:game/components/boost_up.dart';
import 'package:game/utils/collisions_block.dart';
import 'package:game/components/obstacle.dart';
import 'package:game/utils/player_hitbox.dart';
import 'package:game/utils/check_collision.dart';
import 'package:game/game_run.dart';

enum PlayerState { idle, running, jumping, falling, sliding, death, appearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<GameRun>, KeyboardHandler, CollisionCallbacks {
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

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation slidingAnimation;
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation appearingAnimation;

  bool isLeftKeyPressed = false;
  bool isRightKeyPressed = false;
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasSlide = false;
  bool hasDie = false;
  bool endGame = false;
  bool delayExpired = false;
  bool hasBoost = false;

  final double _gravity = 0.77;
  final double _jumpForce = 175;
  final double _terminalVelocity = 270;
  double scaleFactor = 2.2;
  double widthMap = 0;
  double heightMap = 0;
  double horizontalMovement = 1;
  double moveSpeed = 125;
  double fixedDeltaTime = 0.08 / 60;
  double accumulatedTime = 0;

  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();

  List<CollisionsBlock> collisionsBlock = [];

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 13,
    offsetY: 19,
    width: 8,
    height: 12,
  );

  @override
  FutureOr<void> onLoad() {
    Vector2 sizeHitbox = Vector2(size.x / 4.5, size.y / 3);
    double adjustementX = size.x / widthMap;
    double adjustementY = size.y / heightMap;
    Vector2 positionHitbox = Vector2(
      ((position.x * adjustementX) + (size.x * 0.25)) -
          ((sizeHitbox.x / 2) * (adjustementX - 1)),
      position.y * adjustementY -
          (size.y * 0.25) -
          (sizeHitbox.y / 2) +
          (sizeHitbox.y * (adjustementY + 0.20)),
    );

    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y - 20);
    position = Vector2(position.x, position.y - 20);
    scale = Vector2(scaleFactor, scaleFactor);
    add(RectangleHitbox(position: positionHitbox, size: sizeHitbox));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!hasDie && !endGame) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
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
    if (other is Obstacle) {
      respawn();
    }
    if (other is BoostUp) {
      hasBoost = true;
      _startSlideTimer();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void _startSlideTimer() {
    Future.delayed(const Duration(milliseconds: 100), () {
      hasBoost = false;
    });
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Idle ($sizeCharacter).png",
        6,
        textureSize,
        0.15);

    runningAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Run ($sizeCharacter).png",
        8,
        textureSize,
        0.08);

    jumpingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Jump ($sizeCharacter).png",
        5,
        textureSize,
        0.2);

    fallingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Fall ($sizeCharacter).png",
        4,
        textureSize,
        0.1);

    slidingAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Slide ($sizeCharacter).png",
        5,
        textureSize,
        0.06);

    deathAnimation = _spriteAnimation(
        "Sprites/Skins/$character/Death ($sizeCharacter).png",
        8,
        textureSize,
        0.1)
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
        stepTime: 0.08,
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

    if (moveSpeed > 125) {
      playerState = PlayerState.sliding;
    } else if ((velocity.x > 0 || velocity.x < 0) && !hasSlide) {
      hasSlide = false;
      playerState = PlayerState.running;
    }

    if (moveSpeed > 125) {
      playerState = PlayerState.sliding;
    } else if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    if (moveSpeed > 125) {
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
    if (hasSlide || hasBoost) {
      _playSlide(150000, dt);
    }

    if (delayExpired) {
      moveSpeed = 125;
      hasSlide = false;
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _playSlide(int value, double dt) {
    moveSpeed = (value * dt) / 0.42;
    delayExpired = false;
    _startDelay();
  }

  void _startDelay() {
    Future.delayed(const Duration(milliseconds: 50), () {
      delayExpired = true;
    });
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionsBlock) {
      if (checkCollision(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          if (!block.isPlatform) {
            respawn();
          }
          position.x = block.x - hitbox.offsetX - hitbox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          if (!block.isPlatform) {
            respawn();
          }
          position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          break;
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
    if (FlameAudio.bgm.isPlaying) {
      game.audio.stopBgm();
    }

    hasDie = true;
    hasJumped = false;
    current = PlayerState.death;

    await animationTicker?.completed;

    animationTicker?.reset();
    position = Vector2(startingPosition.x, startingPosition.y);
    current = PlayerState.appearing;

    await animationTicker?.completed;

    animationTicker?.reset();
    position = Vector2(startingPosition.x, startingPosition.y);
    hasDie = false;
    game.audio.playBgm("Level03.mp3");
  }

  void reset() {
    hasDie = false;
    position = Vector2(startingPosition.x, startingPosition.y);
    current = PlayerState.idle;
  }
}

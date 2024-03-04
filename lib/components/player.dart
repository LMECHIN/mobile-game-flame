import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/collisions_block.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/components/player_hitbox.dart';
import 'package:flutter_application_1/components/utils.dart';
import 'package:flutter_application_1/pixel_game.dart';

enum PlayerState { idle, running, jumping, falling, sliding, death, appearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, KeyboardHandler, CollisionCallbacks {
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
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation appearingAnimation;

  Color color = const Color.fromARGB(255, 0, 0, 0);

  double _gravity = 5;
  final double _jumpForce = 1800;
  final double _terminalVelocity = 2000;
  double scaleFactor = 0.3;
  double horizontalMovement = 0;
  double moveSpeed = 800;
  double normalMoveSpeed = 800;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double fixedDeltaTime = 0.1 / 60;
  double accumulatedTime = 0;
  bool isOnGround = false;
  bool hasJumped = false;
  bool hasSlide = false;
  bool hasDie = false;
  bool test = false;

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
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    scale = Vector2(scaleFactor, scaleFactor);
    Vector2 sizeHitbox = Vector2(size.x / 4.5, size.y / 3);
    Vector2 positionHitbox = Vector2(position.x / 1, position.y / 5);

    add(RectangleHitbox(size: sizeHitbox, position: positionHitbox));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!hasDie) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions(fixedDeltaTime);
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions(fixedDeltaTime);
        // _checkBoosts();
      }
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
    if (isLeftKeyPressed) {
      test = true;
    }
    if (isRightKeyPressed) {
      test = false;
    }
    horizontalMovement += isRightKeyPressed ? 1 : 0;

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
      _respawn();
      super.onCollisionStart(intersectionPoints, other);
    }
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

    deathAnimation = _spriteAnimation(
        "Sprites/$character/Death ($sizeCharacter).png", 8, textureSize)
      ..loop = false;

    appearingAnimation = _reanimationSpriteAnimation(
        "Sprites/$character/Appearing ($sizeCharacter).png", 3, textureSize);

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

  SpriteAnimation _reanimationSpriteAnimation(
      String sprite, int amount, Vector2 textureSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(sprite),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
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
    if (hasJumped && isOnGround) {
      _playJump(dt);
    }
    if (hasSlide) {
      _playSlide();
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

  void _playSlide() {
    // normalMoveSpeed = moveSpeed;
    moveSpeed = 4000;
    Future.delayed(const Duration(milliseconds: 100), () {
      moveSpeed = 800;
    });
    hasSlide = false;
  }

  void _checkBoosts(double dt) {
    // for (final block in collisionsBlock) {
    //   if (block.isBoost) {
    //     if (checkCollision(this, block)) {
    // const canBoostDuration = Duration(milliseconds: 100);
    // Future.delayed(
    //     canBoostDuration,
    //     () => {
    //           _gravity = 5,
    //         });
    _playJump(dt);
  }
  //   }
  // }
  // }

  void _checkHorizontalCollisions(double dt) {
    for (final block in collisionsBlock) {
      if (!block.isBoost) {
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
      if (block.isBoost) {
        if (checkCollision(this, block)) {
          _playJump(dt);
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions(double dt) {
    for (final block in collisionsBlock) {
      if (block.isBoost) {
        if (checkCollision(this, block)) {
          if (velocity.y < 0) {
            velocity.y = 0;
            // position.y = block.y - hitbox.height - hitbox.offsetY;
            // _checkBoosts(dt);
            // hasJumped = true;
            _playJump(dt);
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

  void _respawn() async {
    print(position);
    const canMoveDuration = Duration(milliseconds: 400);
    hasDie = true;
    current = PlayerState.death;
    Future.delayed(
        canMoveDuration,
        () => {
              _updatePlayerColor(const Color.fromARGB(255, 0, 0, 0)),
            });
    _updatePlayerColor(const Color.fromARGB(255, 250, 250, 250));
    await animationTicker?.completed;
    animationTicker?.reset();

    if (velocity.x < 0 && scale.x < 0) {
      position = Vector2(startingPosition.x + 660, startingPosition.y - 20);
    } else {
      position = Vector2(startingPosition.x, startingPosition.y - 20);
    }

    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    if (velocity.x < 0 && scale.x < 0) {
      position = Vector2(startingPosition.x + 660, startingPosition.y - 20);
    } else {
      position = Vector2(startingPosition.x, startingPosition.y - 20);
    }
    Future.delayed(
        canMoveDuration,
        () => {
              hasDie = false,
            });
  }
}

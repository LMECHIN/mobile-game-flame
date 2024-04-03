import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_1/components/border_blocks.dart';
import 'package:flutter_application_1/components/ground_effect.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/components/texture_blocks.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Blocks extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  int color;
  double speedLoop;
  bool loop;
  List<bool> borders;
  bool hasTextureBlocks;
  final String texture;
  final String groundTexture;
  Blocks({
    position,
    size,
    this.color = 2,
    this.speedLoop = 1,
    this.loop = false,
    this.borders = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    this.hasTextureBlocks = false,
    required this.texture,
    required this.groundTexture,
  }) : super(
          position: position,
          size: size,
        );
  bool _isTransitioning = false;
  double transitionDuration = 0.5;
  double _transitionTimer = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    final hitboxShape = RectangleHitbox(
      angle: -0.1,
    );
    add(hitboxShape);

    // debugMode = true;
    _restoreOriginalAnimation();

    return super.onLoad();
  }

  int _checkBorder() {
    for (int i = 0; i < borders.length; i++) {
      if (borders[i]) {
        return i;
      }
    }
    return 15;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedBlock();
      // _updatePlayerColor(const Color.fromARGB(255, 11, 3, 55));
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isTransitioning) {
      _transitionTimer += dt;
      if (_transitionTimer >= transitionDuration) {
        _isTransitioning = false;
        _transitionTimer = 0;
        _restoreOriginalAnimation();
      }
    }
  }

  void _reachedBlock() {
    final groundEffect = GroundEffect();
    add(groundEffect);
    _isTransitioning = true;
  }

  void _restoreOriginalAnimation() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/blocks.png'),
      SpriteAnimationData.range(
        start: color,
        end: color,
        amount: 10,
        stepTimes: [speedLoop],
        textureSize: Vector2.all(264),
        loop: loop,
      ),
    );
    final int i = _checkBorder();
    final borderBlocks = BorderBlocks(borderIndex: i);
    add(borderBlocks);

    final textureBlocks = TextureBlocks(hasOn: hasTextureBlocks);
    add(textureBlocks);
  }

  void reset() {}
}

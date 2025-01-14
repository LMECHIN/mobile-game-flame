import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:game/components/border_blocks.dart';
import 'package:game/components/ground_effect.dart';
import 'package:game/components/player.dart';
import 'package:game/components/textures/texture_blocks.dart';
import 'package:game/components/textures/texture_cross.dart';
import 'package:game/game_run.dart';

class Blocks extends SpriteAnimationComponent
    with HasGameRef<GameRun>, CollisionCallbacks {
  int color;
  double speedLoop;
  bool loop;
  List<bool> borders;
  bool hasTextureBlocks;
  bool hasTextureCross;
  bool texture;
  Color bluePaintColor;

  Blocks({
    position,
    size,
    this.color = 0,
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
    this.hasTextureCross = false,
    this.texture = true,
    this.bluePaintColor = const Color(0xFF0000FF),
  }) : super(
          position: position,
          size: size,
        );

  late Paint bluePaint;

  @override
  FutureOr<void> onLoad() {
    priority = 0;

    final hitboxShape = RectangleHitbox(
      angle: -0.1,
    );
    add(hitboxShape);
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
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    priority = -1;
    if (texture) {
      bluePaint = Paint()..color = bluePaintColor;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 16.25, 16.25), bluePaint);
    }
    super.render(canvas);
  }

  void _reachedBlock() {
    final groundEffect = GroundEffect(size: Vector2.all(16.25));
    add(groundEffect);
  }

  void _restoreOriginalAnimation() {
    final int i = _checkBorder();
    final borderBlocks = BorderBlocks(
      borderIndex: i,
      size: Vector2.all(16.25),
    );
    add(borderBlocks);

    final textureBlocks = TextureBlocks(
      hasOn: hasTextureBlocks,
      size: Vector2.all(16),
    );
    add(textureBlocks);
    final textureCross = TextureCross(
      hasOn: hasTextureCross,
      size: Vector2.all(16),
    );
    add(textureCross);
  }
}

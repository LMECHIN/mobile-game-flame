import 'package:flame/components.dart';
import 'package:flutter_application_1/pixel_game.dart';

class Particles extends SpriteAnimationComponent with HasGameRef<PixelGame> {
  Particles({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Sprites/14-TileSets/particle.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(264),
        loop: false,
      ),
    );
    super.onLoad();
  }
}

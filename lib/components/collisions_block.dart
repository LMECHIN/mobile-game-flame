import 'package:flame/components.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;
  CollisionsBlock({
    posX,
    posY,
    position,
    size,
    this.isPlatform = false,
  }) : super(
          position: position,
          size: size,
        ) {
    debugMode = true;
  }
}

import 'package:flame/components.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;
  bool isBoost;
  CollisionsBlock({
    posX,
    posY,
    position,
    size,
    this.isPlatform = false,
    this.isBoost = false,
  }) : super(
          position: position,
          size: size,
        ) {
    // debugMode = true;
  }
}

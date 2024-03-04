import 'package:flame/components.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;
  bool isBoostV;
  bool isBoostH;
  CollisionsBlock({
    posX,
    posY,
    position,
    size,
    this.isPlatform = false,
    this.isBoostV = false,
    this.isBoostH = false,
  }) : super(
          position: position,
          size: size,
        ) {
    // debugMode = true;
  }
}

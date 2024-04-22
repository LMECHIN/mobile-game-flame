import 'package:flame/components.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;
  bool isBoostUp;

  CollisionsBlock({
    posX,
    posY,
    position,
    size,
    this.isPlatform = false,
    this.isBoostUp = false,
  }) : super(
          position: position,
          size: size,
        );
}

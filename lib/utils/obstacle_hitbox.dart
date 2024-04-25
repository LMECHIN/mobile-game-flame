import 'package:flame/components.dart';

Map<String, List<Vector2>> triangleHitbox(dynamic size) {
  Map<String, List<Vector2>> directionPoints = {
    "up": [
      Vector2(0, 0),
      Vector2(size.x / 2, size.y),
      Vector2(size.x, 0),
    ],
    "left": [
      Vector2(0, 0),
      Vector2((size.x + 2), (size.y - 8) / 2),
      Vector2(0, size.y),
    ],
    "right": [
      Vector2(size.x, 0),
      Vector2(0, size.y / 2),
      Vector2(size.x, size.y),
    ],
    "down": [
      Vector2(0, size.y),
      Vector2(size.x / 2, 0),
      Vector2(size.x, size.y),
    ],
  };

  return directionPoints;
}

import 'package:flutter/material.dart';

MaterialStateProperty<Color> getColor(Color color, Color colorPressed) {
  return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return colorPressed;
    } else {
      return color;
    }
  });
}

MaterialStateProperty<BorderSide> getBorder(Color color, Color colorPressed) {
  return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return BorderSide(
        color: colorPressed,
        width: 2,
      );
    } else {
      return BorderSide(
        color: color,
        width: 2,
      );
    }
  });
}

MaterialStateProperty<double?>? getElevation(
    double elevation, double elevationPressed) {
  return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return elevationPressed;
    } else {
      return elevation;
    }
  });
}

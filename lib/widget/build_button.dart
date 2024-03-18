import 'package:flutter/material.dart';

class BuildButton {
  Widget buildMenuButton(
      {required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: getColor(Colors.white, Colors.black),
          foregroundColor: getColor(Colors.white, Colors.black),
          side: getBorder(Colors.white, Colors.black54),
          shadowColor: getColor(Colors.white, Colors.black),
          elevation: getElevation(10, 10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            shadows: [
              Shadow(
                blurRadius: 600.0,
                color: Colors.white,
                offset: Offset(20, 0),
              )
            ],
          ),
        ),
      ),
    );
  }

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
}

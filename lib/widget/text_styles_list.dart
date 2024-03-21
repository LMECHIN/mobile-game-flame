import 'package:flutter/material.dart';

class TextStylesList {
  static List<TextStyle> getTextStyles(List<double> sizes) {
    if (sizes.isEmpty) sizes = [125, 125, 125, 125, 125, 125];
    return [
      TextStyle(
        fontSize: sizes[0],
        fontFamily: 'DripOctober',
        color: Colors.blue,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.blue,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
      TextStyle(
        fontSize: sizes[1],
        fontFamily: 'DripOctober',
        color: Colors.green,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.green,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
      TextStyle(
        fontSize: sizes[2],
        fontFamily: 'DripOctober',
        color: Colors.pink,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.pink,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
      TextStyle(
        fontSize: sizes[3],
        fontFamily: 'DripOctober',
        color: Colors.yellow,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.yellow,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
      TextStyle(
        fontSize: sizes[4],
        fontFamily: 'DripOctober',
        color: Colors.red,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.red,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
      TextStyle(
        fontSize: sizes[5],
        fontFamily: 'DripOctober',
        color: Colors.purple,
        shadows: const [
          Shadow(
            blurRadius: 20.0,
            color: Colors.purple,
            offset: Offset(0, 0),
          )
        ],
        decoration: TextDecoration.none,
      ),
    ];
  }
}

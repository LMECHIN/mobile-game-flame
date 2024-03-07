import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pixel_game.dart';


class GamePlay extends StatelessWidget {
  final String level;
  final PixelGame _game;

  GamePlay({Key? key, required this.level})
      : _game = PixelGame(level: level),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
    );
  }
}

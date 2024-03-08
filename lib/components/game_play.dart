import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pixel_game.dart';

class GamePlay extends StatelessWidget {
  final String? level;
  final String? character;
  final PixelGame _game;

  GamePlay({Key? key, this.level, this.character})
      : _game = PixelGame(level: level, character: character),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: GameWidget(
        game: _game,
      ),
    );
  }
}

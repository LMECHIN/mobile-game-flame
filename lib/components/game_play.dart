import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/overlays/end_game.dart';
import 'package:flutter_application_1/overlays/pause_button.dart';
import 'package:flutter_application_1/overlays/pause_menu.dart';
import 'package:flutter_application_1/pixel_game.dart';

class GamePlay extends StatelessWidget {
  final String? level;
  final PixelGame _game;

  GamePlay({super.key, this.level}) : _game = PixelGame(level: level);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GameWidget(
        game: _game,
        initialActiveOverlays: const [PauseButton.id],
        overlayBuilderMap: {
          PauseButton.id: (BuildContext context, PixelGame game) => PauseButton(
                game: game,
              ),
          PauseMenu.id: (BuildContext context, PixelGame game) => PauseMenu(
                game: game,
              ),
          EndGame.id: (BuildContext context, PixelGame game) => EndGame(
                game: game,
              ),
        },
      ),
    );
  }
}

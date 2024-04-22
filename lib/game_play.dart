import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game/overlays/death_game.dart';
import 'package:game/overlays/end_game.dart';
import 'package:game/overlays/pause_button.dart';
import 'package:game/overlays/pause_menu.dart';
import 'package:game/game_run.dart';

class GamePlay extends StatelessWidget {
  final String? level;
  final GameRun _game;
  final BuildContext context;

  GamePlay({super.key, required this.context, this.level})
      : _game = GameRun(
          level: level,
        );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GameWidget(
        game: _game,
        initialActiveOverlays: const [PauseButton.id, DeathGame.id],
        overlayBuilderMap: {
          PauseButton.id: (BuildContext context, GameRun game) => PauseButton(
                game: game,
              ),
          DeathGame.id: (BuildContext context, GameRun game) => DeathGame(
                game: game,
              ),
          PauseMenu.id: (BuildContext context, GameRun game) => PauseMenu(
                game: game,
              ),
          EndGame.id: (BuildContext context, GameRun game) => EndGame(
                game: game,
              ),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:game/overlays/pause_menu.dart';
import 'package:game/game_run.dart';

class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final GameRun game;

  const PauseButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
      child: const Icon(
        Icons.pause_circle,
        color: Colors.white,
      ),
      onPressed: () {
        game.pauseEngine();
        game.audio.pauseBgm();
        game.overlays.add(PauseMenu.id);
        game.overlays.remove(PauseButton.id);
      }
      )
    );
  }
}

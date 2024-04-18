import 'package:flutter/material.dart';
import 'package:flutter_application_1/overlays/pause_menu.dart';
import 'package:flutter_application_1/pixel_game.dart';

class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final PixelGame game;

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

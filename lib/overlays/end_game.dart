import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter_application_1/components/main_menu.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/overlays/pause_menu.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:provider/provider.dart';

class EndGame extends StatelessWidget {
  static const String id = 'EndGame';
  final PixelGame game;

  const EndGame({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final levelData = Provider.of<LevelData>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause menu title.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Level Completed !',
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  )
                ],
                decoration: TextDecoration.none,
              ),
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove(EndGame.id);
                game.reset();
                game.resumeEngine();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        GamePlay(level: levelData.selectedLevel),
                  ),
                );
              },
              child: const Text('Restart'),
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove(PauseMenu.id);
                game.reset();
                game.resumeEngine();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenu(),
                  ),
                );
              },
              child: const Text('Main menu'),
            ),
          ),
        ],
      ),
    );
  }
}

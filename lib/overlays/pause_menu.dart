import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/components/main_menu.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'pause_button.dart';

class PauseMenu extends StatelessWidget {
  static const String id = 'PauseMenu';
  final PixelGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause menu title.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Paused',
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
            width: MediaQuery.of(context).size.width / 7,
            child: BuildButton(
              text: 'Resume',
              size: 0.015,
              colors: const {
                ColorState.backgroundColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.backgroundColorOnPressed: Colors.black,
                ColorState.borderColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.borderColorOnPressed: Colors.black54,
                ColorState.shadowColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.shadowColorOnPressed: Colors.black54,
              },
              onPressed: () {
                game.resumeEngine();
                game.overlays.remove(PauseMenu.id);
                game.overlays.add(PauseButton.id);
              },
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 7,
            child: BuildButton(
              text: 'Restart',
              size: 0.015,
              effects: const {
                EffectState.shimmer: [
                  ShimmerEffect(
                    color: Colors.transparent,
                    duration: Duration(seconds: 0),
                  ),
                ],
              },
              onPressed: () {
                game.overlays.remove(PauseMenu.id);
                game.overlays.add(PauseButton.id);
                game.reset();
                game.resumeEngine();
              },
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 7,
            child: BuildButton(
              text: 'Exit',
              size: 0.015,
              effects: const {
                EffectState.shimmer: [
                  ShimmerEffect(
                    color: Colors.transparent,
                    duration: Duration(seconds: 0),
                  ),
                ],
              },
              colors: const {
                ColorState.backgroundColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.backgroundColorOnPressed: Colors.black,
                ColorState.borderColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.borderColorOnPressed: Colors.black54,
                ColorState.shadowColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.shadowColorOnPressed: Colors.black54,
              },
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
            ),
          ),
        ],
      ),
    );
  }
}

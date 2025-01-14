import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game/game_play.dart';
import 'package:game/menu/main_menu.dart';
import 'package:game/models/level_data.dart';
import 'package:game/overlays/pause_menu.dart';
import 'package:game/game_run.dart';
import 'package:game/widget/build_button.dart';
import 'package:game/widget/text_styles_list.dart';
import 'package:provider/provider.dart';

class EndGame extends StatefulWidget {
  static const String id = 'EndGame';
  final GameRun game;

  const EndGame({super.key, required this.game});

  @override
  State<EndGame> createState() => _EndGameState();
}

class _EndGameState extends State<EndGame> {
  late int selectedIndex;
  late List<TextStyle> textStyles;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    textStyles = TextStylesList.getTextStyles([80, 80, 80, 80, 80, 80]);
    _startTimer();
  }

  void _startTimer() {
    const duration = Duration(seconds: 2);
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        selectedIndex++;
        if (selectedIndex >= textStyles.length) {
          selectedIndex = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelData = Provider.of<LevelData>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex++;
                if (selectedIndex >= textStyles.length) {
                  selectedIndex = 0;
                }
              });
            },
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(seconds: 1),
                style: textStyles[selectedIndex],
                child: const Text(
                  'Level Completed!',
                ),
              ),
            ),
          )
              .animate()
              .fade()
              .scaleXY(
                duration: const Duration(seconds: 1),
                curve: Curves.bounceOut,
              )
              .then(
                delay: const Duration(seconds: 2),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInBack,
              ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 7,
            child: BuildButton(
              text: 'Restart',
              size: 0.015,
              onPressed: () {
                widget.game.overlays.remove(EndGame.id);
                widget.game.reset();
                widget.game.resumeEngine();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GamePlay(
                        context: context, level: levelData.selectedLevel),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 7,
            child: BuildButton(
              text: 'Main menu',
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
                ColorState.backgroundColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.backgroundColorOnPressed: Colors.black,
                ColorState.borderColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.borderColorOnPressed: Colors.black54,
                ColorState.shadowColor: Color.fromARGB(255, 2, 8, 188),
                ColorState.shadowColorOnPressed: Colors.black54,
              },
              onPressed: () {
                widget.game.audio.stopBgm();
                widget.game.overlays.remove(PauseMenu.id);
                widget.game.reset();
                widget.game.resumeEngine();

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

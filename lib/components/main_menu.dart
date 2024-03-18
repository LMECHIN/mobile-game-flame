import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter_application_1/components/levels_menu.dart';
import 'package:flutter_application_1/components/skins_menu.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/utils/get_level_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LevelData>(
      future: getLevelData(),
      builder: (context, AsyncSnapshot<LevelData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          LevelData levelData = snapshot.data!;
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Text(
                      'Game2d',
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
                  BuildButton().buildMenuButton(
                    text: 'Play',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GamePlay(
                            level: levelData.selectedLevel,
                          ),
                        ),
                      );
                    },
                  ),
                  BuildButton().buildMenuButton(
                    text: 'Level',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LevelsMenu(),
                        ),
                      );
                    },
                  ),
                  BuildButton().buildMenuButton(
                    text: 'Skin',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SkinsMenu(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

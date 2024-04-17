import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter_application_1/components/levels_menu.dart';
import 'package:flutter_application_1/components/settings_menu.dart';
import 'package:flutter_application_1/components/skins_menu.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/utils/get_level_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:flutter_application_1/widget/text_styles_list.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late int selectedIndex;
  late List<TextStyle> textStyles;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    textStyles = TextStylesList.getTextStyles([]);
  }

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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: GestureDetector(
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
                          style: textStyles[
                              selectedIndex],
                          child: const Text(
                            'Game2d',
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
                        )
                        .shake(),
                  ),
                  Column(
                    children: [
                      BuildButton(
                        text: 'Play',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => GamePlay(context: context,
                                level: levelData.selectedLevel,
                              ),
                            ),
                          );
                        },
                      ),
                      BuildButton(
                        text: 'Level',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LevelsMenu(),
                            ),
                          );
                        },
                      ),
                      BuildButton(
                        text: 'Skin',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SkinsMenu(),
                            ),
                          );
                        },
                      ),
                      BuildButton(
                        text: 'Settings',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsMenu(),
                            ),
                          );
                        },
                      ),
                    ],
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game/game_play.dart';
import 'package:game/utils/progress_bar.dart';
import 'package:game/models/level_data.dart';
import 'package:game/widget/build_button.dart';
import 'package:game/widget/find_path.dart';
import 'package:provider/provider.dart';

class LevelProgressData {
  final String levelName;
  final double progress;

  LevelProgressData(
    this.levelName,
    this.progress,
  );
}

class LevelsMenu extends StatefulWidget {
  const LevelsMenu({super.key});

  @override
  State<LevelsMenu> createState() => _LevelsMenuState();
}

class _LevelsMenuState extends State<LevelsMenu> {
  late FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelData = Provider.of<LevelData>(context);
    String assetFolderPath = 'assets/tiles/';

    return FutureBuilder<List<LevelProgressData>>(
      future: getFilesWithProgress(assetFolderPath, '.tmx', levelData),
      builder: (context, AsyncSnapshot<List<LevelProgressData>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          List<LevelProgressData>? levelProgressData = snapshot.data;
          if (levelProgressData != null && levelProgressData.isNotEmpty) {
            List<String> cleanedLevels =
                levelProgressData.map((data) => data.levelName).toList();

            return Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: ListWheelScrollView(
                        controller: controller,
                        itemExtent: MediaQuery.of(context).size.width * 0.8,
                        physics: const FixedExtentScrollPhysics(),
                        diameterRatio: 1.5,
                        children: cleanedLevels.asMap().entries.map((entry) {
                          final String level = entry.value;
                          final double progress =
                              levelData.levelProgress[level] ?? 0.0;
                          return RotatedBox(
                            quarterTurns: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Center(
                                        child: Text(level),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1),
                                      ProgressBar(progress: progress),
                                    ],
                                  ),
                                ),
                                BuildButton(
                                  effects: progress == 100
                                      ? {
                                          EffectState.shimmer: [
                                            const ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        }
                                      : {},
                                  colors: const {
                                    ColorState.backgroundColor:
                                        Color.fromARGB(255, 2, 8, 188),
                                    ColorState.backgroundColorOnPressed:
                                        Colors.black,
                                    ColorState.borderColor:
                                        Color.fromARGB(255, 2, 8, 188),
                                    ColorState.borderColorOnPressed:
                                        Colors.black54,
                                    ColorState.shadowColor:
                                        Color.fromARGB(255, 2, 8, 188),
                                    ColorState.shadowColorOnPressed:
                                        Colors.black54,
                                  },
                                  text: 'Select',
                                  onPressed: () {
                                    levelData.selectLevel(level);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => GamePlay(
                                          context: context,
                                          level: level,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: BuildButton(
                      effects: const {
                        EffectState.shimmer: [
                          ShimmerEffect(
                            color: Colors.transparent,
                            duration: Duration(seconds: 0),
                          ),
                        ],
                      },
                      text: 'Back',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      colors: const {
                        ColorState.backgroundColor:
                            Color.fromARGB(255, 188, 2, 2),
                        ColorState.backgroundColorOnPressed: Colors.black,
                        ColorState.borderColor: Color.fromARGB(255, 188, 2, 2),
                        ColorState.borderColorOnPressed: Colors.black54,
                        ColorState.shadowColor: Color.fromARGB(255, 188, 2, 2),
                        ColorState.shadowColorOnPressed: Colors.black54,
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      child: const Icon(Icons.arrow_forward),
                      onTap: () {
                        final nextLevel = controller.selectedItem + 1;

                        controller.animateToItem(nextLevel,
                            duration: const Duration(seconds: 1),
                            curve: Curves.bounceOut);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      child: const Icon(Icons.arrow_back),
                      onTap: () {
                        final nextLevel = controller.selectedItem - 1;

                        controller.animateToItem(nextLevel,
                            duration: const Duration(seconds: 1),
                            curve: Curves.bounceOut);
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No levels found."));
          }
        }
      },
    );
  }
}

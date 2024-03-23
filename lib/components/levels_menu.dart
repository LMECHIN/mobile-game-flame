import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:flutter_application_1/widget/find_path.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LevelProgressData {
  final String levelName;
  final double progress;

  LevelProgressData(this.levelName, this.progress);
}

class LevelsMenu extends StatefulWidget {
  const LevelsMenu({Key? key}) : super(key: key);

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
    controller.dispose(); // Fix: Added parentheses to call dispose method
    super.dispose();
  }

  Color _getColorByPercentage(double percent) {
    if (percent >= 0.7) {
      return Colors.green;
    } else if (percent >= 0.5) {
      return Colors.orange;
    } else {
      return const Color.fromARGB(255, 188, 2, 2);
    }
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
                        itemExtent: 500,
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
                                  width: 400,
                                  height: 200,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      levelData.selectLevel(level);
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => GamePlay(
                                            level: level,
                                          ),
                                        ),
                                      );
                                    },
                                    child: LinearPercentIndicator(
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      alignment: MainAxisAlignment.center,
                                      animateFromLastPercent: true,
                                      animation: true,
                                      lineHeight: 20.0,
                                      animationDuration: 2500,
                                      clipLinearGradient: true,
                                      percent: progress / 100,
                                      center: Text(
                                          "${progress.floorToDouble()}% - $level"),
                                      barRadius: const Radius.circular(80),
                                      progressColor:
                                          _getColorByPercentage(progress / 100),
                                    ),
                                  ),
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

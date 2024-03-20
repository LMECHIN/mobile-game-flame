import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class LevelsMenu extends StatefulWidget {
  const LevelsMenu({super.key});

  @override
  State<LevelsMenu> createState() => _LevelsMenuState();
}

class _LevelsMenuState extends State<LevelsMenu> {
  late FixedExtentScrollController controller;
  static List<String> _assetList = [];

  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController();
  }

  @override
  void dispose() {
    controller.dispose;
    super.dispose();
  }

  Future<List<String>> getFilesInAssetFolder(String folderPath) async {
    if (_assetList.isNotEmpty) {
      return _assetList;
    }

    try {
      String manifest = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> manifestMap = json.decode(manifest);
      _assetList = manifestMap.keys
          .where((String key) =>
              key.startsWith(folderPath) && key.endsWith('.tmx'))
          .map((String key) {
        String fileName = p.basename(key);
        return fileName;
      }).toList();
    } catch (e) {
      print("Error retrieving asset files : $e");
    }

    return _assetList;
  }

  @override
  Widget build(BuildContext context) {
    final levelData = Provider.of<LevelData>(context);
    String assetFolderPath = 'assets/tiles/';
    return FutureBuilder<List<String>>(
      future: getFilesInAssetFolder(assetFolderPath),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          List<String>? levels = snapshot.data;
          if (levels != null && levels.isNotEmpty) {
            List<String> cleanedLevels = levels.map((level) {
              return level.replaceAll('.tmx', '');
            }).toList();

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
                        // perspective: 0.008,
                        children: cleanedLevels.map((level) {
                          return RotatedBox(
                            quarterTurns: 1,
                            child: SizedBox(
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
                                child: Text(level),
                              ),
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

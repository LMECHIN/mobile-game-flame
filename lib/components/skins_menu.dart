import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/models/player_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';

class SkinsMenu extends StatefulWidget {
  const SkinsMenu({super.key});

  @override
  State<SkinsMenu> createState() => _SkinsMenuState();
}

class _SkinsMenuState extends State<SkinsMenu> {
  late FixedExtentScrollController controller;
  static List<String> _assetList = [];
  late Future<List<String>> _skinListFuture;
  int imageIndex = 0;
  int skinSize = 0;
  late final Map<String, List<VideoPlayerController>> _videoPlayerControllers =
      {};

  Future<List<String>> getFoldersInAssetFolder(String folderPath) async {
    List<String> folderList = [];

    try {
      List<String> assetList = await rootBundle
          .loadString('AssetManifest.json')
          .then((String manifest) {
        Map<String, dynamic> manifestMap = json.decode(manifest);
        return manifestMap.keys
            .where((String key) =>
                key.startsWith(folderPath) &&
                key.contains('/') &&
                !key.endsWith('.'))
            .toList();
      });

      for (String assetPath in assetList) {
        List<String> pathComponents = assetPath.split('/');
        if (pathComponents.length > 1) {
          String folderName = pathComponents[4];
          if (!folderList.contains(folderName)) {
            folderList.add(folderName);
          }
        }
      }
    } catch (e) {
      print("Error retrieving asset folders: $e");
    }

    return folderList;
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
              key.startsWith(folderPath) && key.endsWith('.mp4'))
          .map((String key) {
        String fileName = p.basename(key);
        return fileName;
      }).toList();
    } catch (e) {
      print("Error retrieving asset files : $e");
    }

    return _assetList;
  }

  void _loadVideosForSkin(String skin) {
    getFilesInAssetFolder('assets/images/Sprites/Skins/$skin')
        .then((skinMoves) {
      print(skin);
      print(skinMoves);
      if (skinMoves.isNotEmpty) {
        List<VideoPlayerController> controllers = [];
        for (String skinMove in skinMoves) {
          VideoPlayerController controller = VideoPlayerController.asset(
            "assets/video/$skin/$skinMove",
          );
          controller.initialize().then((_) {
            setState(() {});
          });
          controllers.add(controller);
        }
        _videoPlayerControllers[skin] = controllers;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController();
    _skinListFuture = getFoldersInAssetFolder('assets/images/Sprites/Skins/');
    _skinListFuture.then((skins) {
      skinSize = skins.length;
      for (String skin in skins) {
        _loadVideosForSkin(skin);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _videoPlayerControllers.forEach((skin, controllers) {
      controllers.forEach((controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerData = Provider.of<PlayerData>(context);
    return FutureBuilder<List<String>>(
      future: _skinListFuture,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          List<String>? skins = snapshot.data;
          if (skins != null && skins.isNotEmpty) {
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
                        children: skins.map((skin) {
                          return RotatedBox(
                            quarterTurns: 1,
                            child: SizedBox(
                              width: 200,
                              height: 400,
                              child: ElevatedButton(
                                onPressed: () {
                                  playerData.selectSkin(skin);
                                  setState(() {
                                    _videoPlayerControllers[skin]
                                        ?.forEach((controller) {
                                      controller.value.isPlaying
                                          ? controller.pause()
                                          : controller.play();
                                      controller.setLooping(true);
                                    });
                                  });
                                },
                                child: _videoPlayerControllers[skin] != null
                                    ? AspectRatio(
                                        aspectRatio:
                                            _videoPlayerControllers[skin]![0]
                                                .value
                                                .aspectRatio,
                                        child: Stack(
                                          children:
                                              _videoPlayerControllers[skin]!
                                                  .map((controller) {
                                            return VideoPlayer(controller);
                                          }).toList(),
                                        ),
                                      )
                                    : Container(),
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
                            curve: Curves.fastLinearToSlowEaseIn);
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
                            curve: Curves.fastLinearToSlowEaseIn);
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No skins found.",
                style: TextStyle(
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
            );
          }
        }
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/models/player_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:flutter_application_1/widget/find_path.dart';
import 'package:provider/provider.dart';

class SkinsMenu extends StatefulWidget {
  const SkinsMenu({super.key});

  @override
  State<SkinsMenu> createState() => _SkinsMenuState();
}

class _SkinsMenuState extends State<SkinsMenu> {
  late FixedExtentScrollController controller;
  late Future<List<String>> _skinListFuture;
  int imageIndex = 0;
  int skinSize = 0;
  late String currentSkinImage;
  late Map<String, String> skinImages = {};

  @override
  void initState() {
    super.initState();
    controller = FixedExtentScrollController();
    _skinListFuture = getFoldersInAssetFolder('assets/images/Sprites/Skins/');
    _skinListFuture.then((skins) {
      skinSize = skins.length;
      loadSkinImages(skins);
    });
  }

  Future<void> loadSkinImages(List<String> skins) async {
    if (skins.isNotEmpty) {
      List<Future<void>> futures = [];
      for (String skin in skins) {
        String idleImagePath =
            "assets/images/Sprites/Skins/$skin/SkinsMenu/idle.gif";
        String deathImagePath =
            "assets/images/Sprites/Skins/$skin/SkinsMenu/death.gif";
        futures.add(precacheImage(AssetImage(idleImagePath), context));
        futures.add(precacheImage(AssetImage(deathImagePath), context));
        skinImages[skin] = idleImagePath;
      }
      await Future.wait(futures);
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
                        itemExtent: MediaQuery.of(context).size.width * 0.8,
                        physics: const FixedExtentScrollPhysics(),
                        diameterRatio: 1.5,
                        children: skins.map((skin) {
                          return RotatedBox(
                            quarterTurns: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BuildButton(
                                        text: 'Death',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/death.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Slide',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/slide.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Jump',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/jump.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Fall',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/fall.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Appearing',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/appearing.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Run',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/run.gif";
                                          });
                                        },
                                      ),
                                      BuildButton(
                                        text: 'Idle',
                                        size: 0.01,
                                        effects: const {
                                          EffectState.shimmer: [
                                            ShimmerEffect(
                                              color: Colors.transparent,
                                              duration: Duration(seconds: 0),
                                            ),
                                          ],
                                        },
                                        onPressed: () {
                                          setState(() {
                                            skinImages[skin] =
                                                "assets/images/Sprites/Skins/$skin/SkinsMenu/idle.gif";
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      SizedBox(
                                        child: Image.asset(
                                          skinImages[skin]!,
                                          key: UniqueKey(),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                        ),
                                      ),
                                      BuildButton(
                                        text: 'Select',
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
                                        onPressed: () {
                                          playerData.selectSkin(skin);
                                        },
                                      ),
                                    ],
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

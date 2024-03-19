import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/models/player_data.dart';
import 'package:flutter_application_1/widget/build_button.dart';
import 'package:provider/provider.dart';

class SkinsMenu extends StatelessWidget {
  const SkinsMenu({Key? key});

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

  @override
  Widget build(BuildContext context) {
    final playerData = Provider.of<PlayerData>(context);
    String assetFolderPath = 'assets/images/Sprites/Skins/';
    return FutureBuilder<List<String>>(
      future: getFoldersInAssetFolder(assetFolderPath),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: skins.map((skin) {
                            return ElevatedButton(
                              onPressed: () {
                                playerData.selectSkin(skin);
                              },
                              child: Text(skin),
                            );
                          }).toList(),
                        ),
                      ],
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

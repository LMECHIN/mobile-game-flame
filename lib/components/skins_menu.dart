import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/pixel_game.dart';

class SkinsMenu extends StatelessWidget {
  final PixelGame game;

  SkinsMenu({Key? key})
      : game = PixelGame(),
        super(key: key);

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
    String assetFolderPath = 'assets/images/Sprites/Skins/';
    return FutureBuilder<List<String>>(
      future: getFoldersInAssetFolder(assetFolderPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          List<String>? skins = snapshot.data;
          if (skins != null && skins.isNotEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: skins.map((skin) {
                        return ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            game.player.character = skin;
                          },
                          child: Text(skin),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No skins found."));
          }
        }
      },
    );
  }
}

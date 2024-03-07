import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter/services.dart' show rootBundle;

class LevelsMenu extends StatelessWidget {
  const LevelsMenu({Key? key}) : super(key: key);

  Future<List<String>> getFilesInAssetFolder(String folderPath) async {
    List<String> fileList = [];

    try {
      List<String> assetList = await rootBundle
          .loadString('AssetManifest.json')
          .then((String manifest) {
        Map<String, dynamic> manifestMap = json.decode(manifest);
        return manifestMap.keys
            .where((String key) =>
                key.startsWith(folderPath) && key.endsWith('.tmx'))
            .toList();
      });

      for (String assetPath in assetList) {
        fileList.add(assetPath.split('/').last);
      }
    } catch (e) {
      print("Error retrieving asset files : $e");
    }

    return fileList;
  }

  @override
  Widget build(BuildContext context) {
    String assetFolderPath = 'assets/tiles/';
    return FutureBuilder<List<String>>(
      future: getFilesInAssetFolder(assetFolderPath),
      builder: (context, snapshot) {
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
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: cleanedLevels.map((level) {
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => GamePlay(level: level),
                          ),
                        );
                      },
                      child: Text(level),
                    );
                  }).toList(),
                ),
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

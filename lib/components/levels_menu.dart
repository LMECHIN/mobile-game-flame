import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

class LevelsMenu extends StatelessWidget {
  const LevelsMenu({super.key});

  static List<String> _assetList = [];

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
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: cleanedLevels.map((level) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GamePlay(
                                  level: level,
                                ),
                              ),
                            );
                          },
                          child: Text(level),
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
            return const Center(child: Text("No levels found."));
          }
        }
      },
    );
  }
}

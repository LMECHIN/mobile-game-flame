import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/levels_menu.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:path/path.dart' as p;

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

Future<List<LevelProgressData>> getFilesWithProgress(
    String folderPath, String extension, LevelData levelData) async {
  List<LevelProgressData> levelProgressData = [];
  try {
    String manifest = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifest);
    List<String> assetList = manifestMap.keys
        .where((String key) =>
            key.startsWith(folderPath) && key.endsWith(extension))
        .map((String key) {
      String fileName = p.basename(key);
      return fileName;
    }).toList();

    for (var assetName in assetList) {
      double progress = levelData.levelProgress[assetName] ?? 0.0;
      levelProgressData.add(LevelProgressData(assetName, progress));
      print(levelData.levelProgress[assetName]);
    }
  } catch (e) {
    print("Error retrieving asset files : $e");
  }

  return levelProgressData;
}

Future<List<String>> getFilesInAssetFolder(
    String folderPath, String extension) async {
  List<String> assetList = [];
  if (assetList.isNotEmpty) {
    return assetList;
  }

  try {
    String manifest = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifest);
    assetList = manifestMap.keys
        .where((String key) =>
            key.startsWith(folderPath) && key.endsWith(extension))
        .map((String key) {
      String fileName = p.basename(key);
      return fileName;
    }).toList();
  } catch (e) {
    print("Error retrieving asset files : $e");
  }

  return assetList;
}

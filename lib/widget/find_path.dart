import 'dart:convert';

import 'package:flutter/services.dart';
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

Future<List<String>> getFilesInAssetFolder(String folderPath, String extension) async {
  List<String> assetList = [];
  if (assetList.isNotEmpty) {
    return assetList;
  }

  try {
    String manifest = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifest);
    assetList = manifestMap.keys
        .where(
            (String key) => key.startsWith(folderPath) && key.endsWith(extension))
        .map((String key) {
      String fileName = p.basename(key);
      return fileName;
    }).toList();
  } catch (e) {
    print("Error retrieving asset files : $e");
  }

  return assetList;
}

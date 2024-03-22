import 'package:hive/hive.dart';
import 'package:flutter_application_1/models/level_data.dart';

Future<LevelData> getLevelData() async {
  final box = await Hive.openBox<LevelData>(LevelData.levelDataBox);
  LevelData? levelData = box.get(LevelData.levelDataKey);

  if (levelData == null) {
    levelData = LevelData('Level10.tmx');
    await box.put(LevelData.levelDataKey, levelData);
  }

  return levelData;
}

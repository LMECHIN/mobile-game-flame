import 'package:hive/hive.dart';
import 'package:game/models/level_data.dart';

Future<LevelData> getLevelData() async {
  final box = await Hive.openBox<LevelData>(LevelData.levelDataBox);
  LevelData? levelData = box.get(LevelData.levelDataKey);

  if (levelData == null) {
    levelData = LevelData('Level03.tmx');
    await box.put(LevelData.levelDataKey, levelData);
  }

  return levelData;
}

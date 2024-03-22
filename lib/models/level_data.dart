import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'level_data.g.dart';

@HiveType(typeId: 1)
class LevelData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(0)
  late String selectedLevel;

  @HiveField(1)
  late double progressBar;

  @HiveField(2)
  Map<String, double> levelProgress = {};

  static const String levelDataBox = 'LevelDataBox';
  static const String levelDataKey = 'LevelDataKey';

  LevelData(this.selectedLevel, this.progressBar);

  void selectLevel(String level) {
    selectedLevel = level;
    notifyListeners();
    save();
  }

  void updateLevelProgress(String levelName, double progress) {
    levelProgress[levelName] = progress;
    notifyListeners();
    save();
  }
}

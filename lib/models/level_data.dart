import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'level_data.g.dart';

@HiveType(typeId: 1)
class LevelData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(0)
  late String selectedLevel;

  @HiveField(1)
  Map<String, double> levelProgress = {"": 0};

  static const String levelDataBox = 'LevelDataBox';
  static const String levelDataKey = 'LevelDataKey';

  LevelData(this.selectedLevel);

  void selectLevel(String level) {
    selectedLevel = level;
    notifyListeners();
    save();
  }

  void selectLevelProgress(double progress) {
    levelProgress[selectedLevel] = progress;
    notifyListeners();
    save();
  }
}

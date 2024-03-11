import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'level_data.g.dart';

@HiveType(typeId: 1)
class LevelData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(0)
  late String selectedLevel;

  static const String levelDataBox = 'LevelDataBox';
  static const String levelDataKey = 'LevelDataKey';

  LevelData(this.selectedLevel);

  void selectLevel(String level) {
    selectedLevel = level;
    notifyListeners();
    save();
  }
}

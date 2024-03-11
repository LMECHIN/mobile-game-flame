import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'player_data.g.dart';

@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(0)
  late String selectedSkin;

  static const String playerDataBox = 'PlayerDataBox';
  static const String playerDataKey = 'PlayerData';

  PlayerData(this.selectedSkin);

  String getSkin() {
    return selectedSkin;
  }

  void selectSkin(String skin) {
    selectedSkin = skin;
    notifyListeners();
    save();
  }
}

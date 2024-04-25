import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
part 'setting_data.g.dart';

@HiveType(typeId: 2)
class SettingData extends ChangeNotifier with HiveObjectMixin {
  static const String settingDataBox = 'SettingDataBox';
  static const String settingDataKey = 'SettingDataKey';

  @HiveField(0)
  bool _sfx = false;
  bool get soundEffects => _sfx;
  set soundEffects(bool value) {
    _sfx = value;
    notifyListeners();
    save();
  }

  @HiveField(1)
  bool _bgm = false;
  bool get backgroundMusic => _bgm;
  set backgroundMusic(bool value) {
    _bgm = value;
    notifyListeners();
    save();
  }

  SettingData({
    bool soundEffects = true,
    bool backgroundMusic = true,
  })  : _bgm = backgroundMusic,
        _sfx = soundEffects;
}

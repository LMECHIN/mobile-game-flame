import 'package:hive/hive.dart';
import 'package:game/models/setting_data.dart';

Future<SettingData> getSettingData() async {
  final box = await Hive.openBox<SettingData>(SettingData.settingDataBox);
  SettingData? settingData = box.get(SettingData.settingDataKey);

  if (settingData == null) {
    settingData = SettingData(
      backgroundMusic: true,
      soundEffects: true,
    );
    await box.put(SettingData.settingDataKey, settingData);
  }

  return settingData;
}

import 'package:hive/hive.dart';
import 'package:flutter_application_1/models/player_data.dart';

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  PlayerData? playerData = box.get(PlayerData.playerDataKey);

  if (playerData == null) {
    playerData = PlayerData('01-King Human');
    await box.put(PlayerData.playerDataKey, playerData);
  }

  return playerData;
}

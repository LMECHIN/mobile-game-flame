import 'package:hive/hive.dart';
import 'package:game/models/player_data.dart';

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);
  PlayerData? playerData = box.get(PlayerData.playerDataKey);

  if (playerData == null) {
    playerData = PlayerData('KingHuman');
    await box.put(PlayerData.playerDataKey, playerData);
  }

  return playerData;
}

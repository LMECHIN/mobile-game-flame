import 'package:hive_flutter/hive_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/main_menu.dart';
import 'package:flutter_application_1/components/player_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  await initHive();

  runApp(
    MultiProvider(
      providers: [
        FutureProvider<PlayerData>(
          create: (BuildContext context) => getPlayerData(),
          initialData: PlayerData('02-King Pig'),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const MainMenu(),
      ),
    ),
  );
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PlayerDataAdapter());
}

Future<PlayerData> getPlayerData() async {
  // Ouvrez la boîte de données du joueur
  final box = await Hive.openBox<PlayerData>(PlayerData.playerDataBox);

  // Obtenez les données du joueur à partir de la boîte
  PlayerData? playerData = box.get(PlayerData.playerDataKey);

  // Si les données du joueur sont nulles, initialisez-les avec une valeur par défaut
  if (playerData == null) {
    playerData = PlayerData('02-King Pig'); // Skin par défaut
    await box.put(PlayerData.playerDataKey, playerData);
  }

  return playerData;
}


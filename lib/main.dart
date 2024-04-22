import 'package:game/models/level_data.dart';
import 'package:game/models/setting_data.dart';
import 'package:game/utils/get_level_data.dart';
import 'package:game/utils/get_player_data.dart';
import 'package:game/utils/get_setting_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:game/menu/main_menu.dart';
import 'package:game/models/player_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();

  runApp(
    MultiProvider(
      providers: [
        FutureProvider<PlayerData>(
          create: (BuildContext context) => getPlayerData(),
          initialData: PlayerData('KingHuman'),
        ),
        FutureProvider<LevelData>(
          create: (BuildContext context) => getLevelData(),
          initialData: LevelData('Level03.tmx'),
        ),
        FutureProvider<SettingData>(
          create: (BuildContext context) => getSettingData(),
          initialData: SettingData(
            backgroundMusic: true,
            soundEffects: true,
          ),
        ),
      ],
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingData>.value(
              value: Provider.of<SettingData>(context),
            ),
          ],
          child: child,
        );
      },
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
  Hive.registerAdapter(LevelDataAdapter());
  Hive.registerAdapter(SettingDataAdapter());
}

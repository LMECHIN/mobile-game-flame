// import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/utils/get_level_data.dart';
import 'package:flutter_application_1/utils/get_player_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/main_menu.dart';
import 'package:flutter_application_1/models/player_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  await initHive();
  // FlutterError.onError = (details) {
  //   FlutterError.presentError(details);
  //   if (kReleaseMode) exit(1);
  // };
  runApp(
    MultiProvider(
      providers: [
        FutureProvider<PlayerData>(
          create: (BuildContext context) => getPlayerData(),
          initialData: PlayerData('KingHuman'),
        ),
        FutureProvider<LevelData>(
          create: (BuildContext context) => getLevelData(),
          initialData: LevelData('Level10'),
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
  Hive.registerAdapter(LevelDataAdapter());
}

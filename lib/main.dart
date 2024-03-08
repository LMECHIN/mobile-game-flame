import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/main_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  // runApp(GameWidget(game: kDebugMode ? const MainMenu() : menu));
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark(),
    home: MainMenu(),
  ));
}

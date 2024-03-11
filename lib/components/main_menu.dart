import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/levels_menu.dart';
import 'package:flutter_application_1/components/skins_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text('Game2d'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LevelsMenu(),
                  ),
                );
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SkinsMenu(),
                  ),
                );
              },
              child: const Text('Skin'),
            ),
          ],
        ),
      ),
    );
  }
}

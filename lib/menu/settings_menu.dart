import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game/models/setting_data.dart';
import 'package:game/widget/build_button.dart';
import 'package:provider/provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Selector<SettingData, bool>(
                        selector: (context, settings) => settings.soundEffects,
                        builder: (context, value, child) {
                          return SwitchListTile(
                            title: const Text('Sound Effects'),
                            value: value,
                            onChanged: (newValue) {
                              Provider.of<SettingData>(context, listen: false)
                                  .soundEffects = newValue;
                            },
                          );
                        },
                      ),
                      Selector<SettingData, bool>(
                        selector: (context, settings) =>
                            settings.backgroundMusic,
                        builder: (context, value, child) {
                          return SwitchListTile(
                            title: const Text('Background Music'),
                            value: value,
                            onChanged: (newValue) {
                              Provider.of<SettingData>(context, listen: false)
                                  .backgroundMusic = newValue;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: BuildButton(
              effects: const {
                EffectState.shimmer: [
                  ShimmerEffect(
                    color: Colors.transparent,
                    duration: Duration(seconds: 0),
                  ),
                ],
              },
              text: 'Back',
              onPressed: () {
                Navigator.of(context).pop();
              },
              colors: const {
                ColorState.backgroundColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.backgroundColorOnPressed: Colors.black,
                ColorState.borderColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.borderColorOnPressed: Colors.black54,
                ColorState.shadowColor: Color.fromARGB(255, 188, 2, 2),
                ColorState.shadowColorOnPressed: Colors.black54,
              },
            ),
          ),
        ],
      ),
    );
  }
}

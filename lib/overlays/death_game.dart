import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/game_play.dart';
import 'package:flutter_application_1/models/level_data.dart';
import 'package:flutter_application_1/pixel_game.dart';
import 'package:provider/provider.dart';

class DeathGame extends StatefulWidget {
  static const String id = 'DeathGame';
  final PixelGame game;

  const DeathGame({super.key, required this.game});

  @override
  State<DeathGame> createState() => _DeathGameState();
}

class _DeathGameState extends State<DeathGame> {
  late Timer _timer;
  late LevelData _levelData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levelData = Provider.of<LevelData>(context);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.game.player.hasDie) {
        _timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                GamePlay(context: context, level: _levelData.selectedLevel),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

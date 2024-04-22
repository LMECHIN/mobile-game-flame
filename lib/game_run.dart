import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game/components/audio.dart';
import 'package:game/components/buttons/button_jump.dart';
import 'package:game/components/level.dart';
import 'package:game/components/player.dart';
import 'package:game/models/player_data.dart';
import 'package:game/utils/get_player_data.dart';

class GameRun extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  String? level;

  GameRun({
    this.level,
  });

  late CameraComponent cam;
  late Player player;
  late Level createLevel;
  late JoystickComponent joystick;
  late Audio audio;
  late List<ParallaxComponent> parallaxComponents = [];

  bool showControls = true;
  bool isBackgroundLoaded = false;
  bool musicPlaying = false;

  int horizontalMovementTotal = 0;

  double camSpeed = 800;
  double targetZoom = 1.0;
  static const double zoomSpeed = 0.9;
  double speedBackground = 20;

  Color color = Colors.black;
  Color colorBottom = Colors.black;

  void updateBackgroundColor(Color newColor) {
    color = newColor;
  }

  void updateBackgroundColorBottom(Color newColor) {
    colorBottom = newColor;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color,
    );

    super.render(canvas);
  }

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();
    await images.loadAllImages();
    audio = Audio(level);
    PlayerData playerData = await getPlayerData();
    player = Player(character: playerData.selectedSkin);

    createLevel = Level(
      player: player,
      levelName: level,
    );
    cam = CameraComponent.withFixedResolution(
      world: createLevel,
      width: 1220,
      height: 550,
    );
    setZoom(4);
    cam.priority = 0;

    if (showControls) {
      add(ButtonJump());
    }

    cam.viewfinder.anchor = const Anchor(0.30, 0.44);
    cam.follow(
      player,
    );
    addAll([audio, cam, createLevel]);
    await super.onLoad();
  }

  @override
  void onAttach() {
    String musicLevel = level!.replaceAll(".tmx", ".mp3");

    if (musicPlaying == false) {
      audio.playBgm(musicLevel);
      musicPlaying = true;
    }
    super.onAttach();
  }

  @override
  void onDetach() {
    if (!FlameAudio.bgm.isPlaying && musicPlaying) {
      audio.stopBgm();
    }
    super.onDetach();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateZoom(dt);
  }

  void reset() async {
    player.reset();
  }

  void setZoom(double zoom) {
    targetZoom = zoom;
  }

  void updateZoom(double dt) {
    cam.viewfinder.zoom = targetZoom;
  }
}

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/audio.dart';
import 'package:flutter_application_1/components/button_jump.dart';
// import 'package:flutter_application_1/components/button_slide.dart';
import 'package:flutter_application_1/components/level.dart';
import 'package:flutter_application_1/components/player.dart';
import 'package:flutter_application_1/models/player_data.dart';
import 'package:flutter_application_1/utils/get_player_data.dart';
import 'package:flutter_application_1/widget/find_path.dart';

class PixelGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  String? level;
  PixelGame({
    this.level,
  });

  late CameraComponent cam;
  double camSpeed = 800;
  late Player player;
  late Level createLevel;
  late JoystickComponent joystick;
  bool showControls = true;
  int horizontalMovementTotal = 0;
  double targetZoom = 1.0;
  static const double zoomSpeed = 0.9;
  Color color = Colors.black;
  Color colorBottom = Colors.black;
  double speedBackground = 20;
  bool isBackgroundLoaded = false;
  late List<ParallaxComponent> parallaxComponents = [];
  bool musicPlaying = false;
  late Audio audio;

  void updateBackgroundColor(Color newColor) {
    color = newColor;
  }

  void updateBackgroundColorBottom(Color newColor) {
    colorBottom = newColor;
  }

  @override
  void render(Canvas canvas) {
    // final double topHeight = size.y / 1.195;
    // final double bottomHeight = size.y - topHeight;
    // final camY = cam.viewfinder.position.y;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color,
    );

    // canvas.drawRect(
    //   Rect.fromLTWH(0, size.y - bottomHeight - camY, size.x, bottomHeight + 1000),
    //   Paint()..color = colorBottom,
    // );

    super.render(canvas);
  }

  void updateSpeedBackground(double newSpeed) {
    speedBackground = newSpeed;
  }

  void parallaxBackground() async {
    String? clearLevel = level!.replaceAll(".tmx", "");
    List<String> backgroundFiles = await getFilesInAssetFolder(
        'assets/images/Background/$clearLevel/', '.png');

    List<ParallaxImageData> images = [];

    for (String file in backgroundFiles) {
      images.add(ParallaxImageData('Background/$clearLevel/$file'));
    }

    ParallaxComponent background = await loadParallaxComponent(
      images,
      baseVelocity: Vector2(speedBackground, 0),
      velocityMultiplierDelta: Vector2(1.6, 1.0),
      priority: -1,
    );
    add(background);
    parallaxComponents.add(background);
    isBackgroundLoaded = true;
  }

  void playMusic() {
    String clearLevel = level!.replaceAll(".tmx", ".mp3");
    if (!musicPlaying) {
      FlameAudio.play(clearLevel, volume: 0.4);
      musicPlaying = true;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();
    await images.loadAllImages();
    audio = Audio();
    // parallaxBackground();
    // playMusic();
    PlayerData playerData = await getPlayerData();
    player = Player(character: playerData.selectedSkin);

    createLevel = Level(
      player: player,
      levelName: level,
    );
    cam = CameraComponent.withFixedResolution(
      world: createLevel,
      width: 4880,
      height: 2200,
    );
    setZoom(3.5);
    cam.priority = 0;
    if (showControls) {
      // addJoystick();
      add(ButtonJump());
      // add(ButtonSlide());
    }
    cam.viewfinder.anchor = const Anchor(0.30, 0.4);
    cam.follow(
      player,
      maxSpeed: double.infinity,
      // horizontalOnly: true,
      snap: true,
    );
    await addAll([audio, cam, createLevel]);
    await super.onLoad();
  }

  @override
  void onAttach() {
    audio.playBgm("Level03.mp3");
    super.onAttach();
  }

  @override
  void onDetach() {
    if (!FlameAudio.bgm.isPlaying) {
      audio.stopBgm();
    }
    super.onDetach();
  }

  @override
  void update(double dt) {
    // if (showControls) {
    //   updateJoystick();
    // }

    // cam.viewfinder.anchor = const Anchor(0.15, 0);
    updateZoom(dt);
    // updateCam(dt);
    super.update(dt);

    // if (player.hasSlide && !player.hasDie) {
    //   updateSpeedBackground(200);
    //   updateParallaxVelocity();
    //   camSpeed = 4000;
    //   Future.delayed(const Duration(milliseconds: 50), () {
    //     updateSpeedBackground(20);
    //     updateParallaxVelocity();
    //   });
    // }
  }

  void updateParallaxVelocity() {
    for (final component in parallaxComponents) {
      component.parallax?.baseVelocity = Vector2(speedBackground, 0.0);
    }
  }

  void reset() async {
    player.reset();
    // if (FlameAudio.bgm.isPlaying) {
    //   audio.stopBgm();
    // }
    // await Future.delayed(const Duration(milliseconds: 400));
    // audio.playBgm("Level03.mp3");
    color = Colors.black;
    // createLevel.reset();
  }

  void setZoom(double zoom) {
    targetZoom = zoom;
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      background: CircleComponent(
        radius: 48,
        paint: Paint()..color = const Color(0xFF000000),
      ),
      knob: CircleComponent(
        radius: 32,
        paint: Paint()..color = const Color(0xFFFFFFFF),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    horizontalMovementTotal = 0;

    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        horizontalMovementTotal -= 1;

        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        horizontalMovementTotal += 1;

        break;
      default:
        break;
    }
    player.horizontalMovement = horizontalMovementTotal.toDouble();
  }

  void updateCam(double dt) {
    double maxSpeed = 150;
    double fallSpeed = player.velocity.y.abs();
    double timeInZone = 0;

    if (fallSpeed > 0) {
      maxSpeed += fallSpeed * 0.8;
    }

    if ((player.position.y > 892 && player.position.y <= 1084)) {
      timeInZone += dt;
      if (timeInZone >= 0.01) {
        cam.moveTo(Vector2(player.position.x, -192), speed: maxSpeed);
        cam.follow(
          player,
          maxSpeed: maxSpeed,
          horizontalOnly: true,
          snap: false,
        );
      }
    } else if ((player.position.y > 700 && player.position.y <= 892)) {
      timeInZone += dt;
      if (timeInZone >= 0.01) {
        cam.moveTo(Vector2(player.position.x, -384), speed: maxSpeed);
        cam.follow(
          player,
          maxSpeed: maxSpeed,
          horizontalOnly: true,
          snap: false,
        );
      }
    } else if ((player.position.y > 508 && player.position.y <= 700)) {
      timeInZone += dt;
      if (timeInZone >= 0.01) {
        cam.moveTo(Vector2(player.position.x, -576), speed: maxSpeed);
        cam.follow(
          player,
          maxSpeed: maxSpeed,
          horizontalOnly: true,
          snap: false,
        );
      }
    } else if (player.position.y <= 508) {
      timeInZone += dt;
      if (timeInZone >= 0.01) {
        cam.moveTo(Vector2(player.position.x, -768), speed: maxSpeed);
        cam.follow(
          player,
          maxSpeed: maxSpeed,
          horizontalOnly: true,
          snap: false,
        );
      }
    } else if (player.position.y > 1084) {
      timeInZone = 0;
      cam.moveTo(Vector2(player.position.x, 0), speed: 750);
      cam.follow(
        player,
        maxSpeed: 750,
        horizontalOnly: true,
        snap: false,
      );
    }
  }

  void updateZoom(double dt) {
    cam.viewfinder.zoom = targetZoom;
  }
}

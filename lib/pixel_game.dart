import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button_jump.dart';
import 'package:flutter_application_1/components/button_slide.dart';
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
  bool showControls = false;
  int horizontalMovementTotal = 0;
  double targetZoom = 1.0;
  static const double zoomSpeed = 0.9;
  Color color = Colors.black;
  double speedBackground = 20;
  bool isBackgroundLoaded = false;
  late List<ParallaxComponent> parallaxComponents = [];

  void updateBackgroundColor(Color newColor) {
    color = newColor;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = color);
    super.render(canvas);
  }

  // @override
  // void render(Canvas canvas) {
  //   final Rect backgroundRect = Rect.fromLTWH(0, 0, size.x, size.y);
  //   final image = images.fromCache('/Background/Blue.png'); // Chemin de l'image de fond
  //   canvas.drawImageRect(image, backgroundRect, backgroundRect, Paint());
  //   super.render(canvas);
  // }

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

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    parallaxBackground();
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

    // cam.viewfinder.anchor = const Anchor(0.15, 0.60);
    // setZoom(2.5);
    cam.priority = 0;
    if (showControls) {
      addJoystick();
      add(ButtonJump());
      add(ButtonSlide());
    }

    addAll([cam, createLevel]);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }

    cam.viewfinder.anchor = const Anchor(0.15, -1.8);
    cam.follow(
      player,
      maxSpeed: double.infinity,
      horizontalOnly: true,
      snap: false,
    );
    updateCam();

    updateZoom(dt);
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

  void reset() {
    player.reset();
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

  void updateCam() {
    double maxSpeed = 750;
    double fallSpeed = player.velocity.y.abs();

    if (fallSpeed > 0) {
      maxSpeed += fallSpeed * 0.5;
    }

    if (player.position.y > 2364 && player.position.y <= 3420) {
      cam.moveTo(Vector2(player.position.x, -1584), speed: maxSpeed);
    } else if (player.position.y > 1308 && player.position.y <= 2364) {
      cam.moveTo(Vector2(player.position.x, -2376), speed: maxSpeed);
    } else if (player.position.y > 252 && player.position.y <= 1308) {
      cam.moveTo(Vector2(player.position.x, -3168), speed: maxSpeed);
    } else if (player.position.y <= 252) {
      cam.moveTo(Vector2(player.position.x, -3960), speed: maxSpeed);
    } else {
      cam.moveTo(Vector2(player.position.x, 0), speed: maxSpeed);
    }

    cam.follow(
      player,
      maxSpeed: maxSpeed,
      horizontalOnly: true,
      snap: false,
    );
  }

  void updateZoom(double dt) {
    final currentZoom = cam.viewfinder.zoom;
    final diff = targetZoom - currentZoom;
    final zoomIncrement = zoomSpeed * dt;
    final newZoom = currentZoom + (diff.clamp(-zoomIncrement, zoomIncrement));

    cam.viewfinder.zoom = newZoom;
  }
}

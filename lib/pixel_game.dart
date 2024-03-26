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

class PixelGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  String? level;
  // final BuildContext context;
  // final double widthResolution;
  // final double heightResolution;
  PixelGame(
      {
      // {required this.widthResolution,
      // required this.heightResolution,
      // required this.context,
      this.level});

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

  void updateBackgroundColor(Color newColor) {
    color = newColor;
  }

  // @override
  // void render(Canvas canvas) {
  //   final Rect backgroundRect = Rect.fromLTWH(0, 0, size.x, size.y);
  //   final image = images.fromCache('/Background/Blue.png'); // Chemin de l'image de fond
  //   canvas.drawImageRect(image, backgroundRect, backgroundRect, Paint());
  //   super.render(canvas);
  // }

  void _parallaxBackgroung() async {
    ParallaxComponent background = await loadParallaxComponent(
      [
        // ParallaxImageData('Background/Starfield_01-1024x1024.png'),
        ParallaxImageData('Background/Starfield_02-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_03-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_04-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_05-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_06-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_07-1024x1024.png'),
        // ParallaxImageData('Background/Starfield_08-1024x1024.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.6, 1.0),
      priority: -1,
    );
    add(background);
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _parallaxBackgroung();
    PlayerData playerData = await getPlayerData();
    player = Player(character: playerData.selectedSkin);

    createLevel = Level(
      player: player,
      levelName: level,
    );
    cam = CameraComponent.withFixedResolution(
      world: createLevel,
      width: 14774,
      height: 6272,
    );

    setZoom(2.5);
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

    cam.viewfinder.anchor = const Anchor(0.15, -1.4);

    cam.follow(
      // maxSpeed: 4000,
      player,
      horizontalOnly: true,
      snap: false,
    );
    updateZoom(dt);
    super.update(dt);
    if (player.hasSlide && !player.hasDie) {
      camSpeed = 4000;
    }
  }

  void reset() {
    player.reset();
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

  void updateZoom(double dt) {
    final currentZoom = cam.viewfinder.zoom;
    final diff = targetZoom - currentZoom;
    final zoomIncrement = zoomSpeed * dt;
    final newZoom = currentZoom + (diff.clamp(-zoomIncrement, zoomIncrement));

    cam.viewfinder.zoom = newZoom;
  }
}

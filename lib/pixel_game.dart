import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/components/button_jump.dart';
import 'package:flutter_application_1/components/level.dart';
import 'package:flutter_application_1/components/player.dart';

class PixelGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, TapCallbacks {
  @override
  Color backgroundColor() => const Color.fromARGB(255, 63, 56, 81);

  late CameraComponent cam;
  Player player = Player(character: '01-King Human');
  late JoystickComponent joystick;
  bool showControls = false;
  int horizontalMovementTotal = 0;
  late double targetZoom = 1.0;
  static const double zoomSpeed = 0.5;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      player: player,
      levelName: 'Level02',
    );
    cam = CameraComponent.withFixedResolution(
        world: world, width: 1280, height: 720);
    cam.follow(
      player,
      maxSpeed: 200,
      snap: true,
    );
    // cam.viewfinder.zoom = 2;
    setZoom(2);
    cam.viewfinder.anchor = Anchor.center;
    cam.priority = 0;
    if (showControls) {
      addJoystick();
      add(ButtonJump());
    }
    addAll([cam, world]);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    updateZoom(dt);
    super.update(dt);
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

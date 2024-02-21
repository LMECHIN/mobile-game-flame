import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
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
  bool showControls = true;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      player: player,
      levelName: 'Level02',
    );

    cam = CameraComponent.withFixedResolution(
        world: world, width: 1280, height: 720);
    cam.viewfinder.anchor = Anchor.topLeft;
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
    super.update(dt);
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
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}

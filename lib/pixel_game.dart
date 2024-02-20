import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_application_1/levels/level.dart';
import 'package:flutter_application_1/actors/player.dart';

class PixelGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color.fromARGB(255, 63, 56, 81);
  late CameraComponent cam;
  Player player = Player(character: '01-King Human');
  late JoystickComponent joystick;

@override
FutureOr<void> onLoad() async {
  // Load all images into cache
  await images.loadAllImages();

  final world = Level(
    player: player,
    levelName: 'Level02',
  );

  cam = CameraComponent.withFixedResolution(
      world: world, width: 1280, height: 720);
  cam.viewfinder.anchor = Anchor.topLeft;
  cam.priority = 0;

  add(cam); // Ajouter la caméra en premier
  add(world); // Ajouter le niveau en deuxième
  addJoystick(); // Ajouter le joystick

  await super.onLoad(); // Attendre que les composants chargent

}

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
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

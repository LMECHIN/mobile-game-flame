import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/components/button_jump.dart';
import 'package:flutter_application_1/components/button_slide.dart';
import 'package:flutter_application_1/components/level.dart';
import 'package:flutter_application_1/components/player.dart';

class PixelGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {

  late CameraComponent cam;
  double camSpeed = 800;
  Player player = Player(character: '01-King Human');
  late JoystickComponent joystick;
  bool showControls = false;
  int horizontalMovementTotal = 0;
  late double targetZoom = 1.0;
  static const double zoomSpeed = 0.9;

  Color color = const Color.fromARGB(255, 0, 0, 0);

  void updateBackgroundColor(Color newColor) {
    color = newColor;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = color);
    super.render(canvas);
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      player: player,
      levelName: 'Level08',
    );
    cam = CameraComponent.withFixedResolution(
        // world: world, width: 1900, height: 920);
        world: world,
        width: 9080,
        height: 5221);

    cam.viewfinder.anchor = const Anchor(0.29, 0.5);
    setZoom(2.4);
    cam.priority = 0;
    if (showControls) {
      addJoystick();
      add(ButtonJump());
      add(ButtonSlide());
    }
    addAll([cam, world]);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    if (player.velocity.x < 0) {
      cam.viewfinder.anchor = const Anchor(0.45, 0.5);
    } else if (player.velocity.x > 0) {
      cam.viewfinder.anchor = const Anchor(0.29, 0.5);
    }
    cam.follow(
      player,
      maxSpeed: camSpeed,
      snap: true,
    );
    updateZoom(dt);
    super.update(dt);
    if (player.hasSlide) {
      camSpeed = 4000;
    }
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

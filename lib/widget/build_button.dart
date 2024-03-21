import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/widget/material_property.dart';

enum ColorState {
  backgroundColor,
  backgroundColorOnPressed,
  borderColor,
  borderColorOnPressed,
  shadowColor,
  shadowColorOnPressed,
  textColor,
}

enum EffectState {
  move,
  shimmer,
}

class BuildButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Map<ColorState, Color> colors;
  final Map<EffectState, List<Effect<dynamic>>> effects;
  final double? size;
  const BuildButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colors = const {},
    this.effects = const {},
    this.size = 25,
  });

  @override
  State<BuildButton> createState() => _BuildButtonState();
}

class _BuildButtonState extends State<BuildButton> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Effect<dynamic>>? moveEffects = [];
    if (widget.effects.containsKey(EffectState.move)) {
      moveEffects = widget.effects[EffectState.move];
    } else {
      moveEffects = [
        const MoveEffect(
          duration: Duration(seconds: 1),
          curve: Curves.bounceOut,
        ),
      ];
    }
    List<Effect<dynamic>>? shimmerEffects = [];
    if (widget.effects.containsKey(EffectState.shimmer)) {
      shimmerEffects = widget.effects[EffectState.shimmer];
    } else {
      shimmerEffects = [
        const ShimmerEffect(
          color: Colors.white,
          duration: Duration(seconds: 1),
        ),
      ];
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Animate(
        effects: moveEffects,
        child: Animate(
          key: UniqueKey(),
          effects: shimmerEffects,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              backgroundColor: getColor(
                widget.colors[ColorState.backgroundColor] ?? Colors.white,
                widget.colors[ColorState.backgroundColorOnPressed] ??
                    Colors.black,
              ),
              side: getBorder(
                widget.colors[ColorState.borderColor] ?? Colors.white,
                widget.colors[ColorState.borderColorOnPressed] ??
                    Colors.black54,
              ),
              shadowColor: getColor(
                widget.colors[ColorState.shadowColor] ?? Colors.white,
                widget.colors[ColorState.shadowColorOnPressed] ?? Colors.black,
              ),
              elevation: getElevation(10, 10),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.black,
                fontSize: widget.size,
                fontFamily: 'DripOctober',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

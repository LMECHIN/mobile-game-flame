import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressBar extends StatefulWidget {
  final double progress;
  const ProgressBar({super.key, required this.progress});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late Timer _timer;
  bool isAnimated = false;
  bool linearAnimated = false;

  Color _getColorByPercentage(double percent) {
    if (percent == 1.0) {
      isAnimated = true;
    }
    if (percent >= 1.0) {
      return const Color.fromARGB(255, 0, 77, 64);
    } else if (percent >= 0.70) {
      return const Color.fromARGB(255, 62, 38, 67);
    } else if (percent >= 0.40) {
      return const Color.fromARGB(255, 150, 98, 2);
    } else {
      return const Color.fromARGB(255, 102, 0, 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        linearAnimated = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      key: UniqueKey(),
      autoPlay: isAnimated,
      effects: const [
        ShimmerEffect(
          color: Colors.white,
          duration: Duration(seconds: 1),
        ),
      ],
      child: LinearPercentIndicator(
        width: MediaQuery.of(context).size.width / 3,
        alignment: MainAxisAlignment.center,
        animateFromLastPercent: true,
        animation: !linearAnimated,
        lineHeight: 25.0,
        animationDuration: 2500,
        maskFilter: const MaskFilter.blur(BlurStyle.normal, 5),
        percent: widget.progress / 100,
        center: Text("${widget.progress.floorToDouble()}%"),
        barRadius: const Radius.circular(20),
        progressColor: _getColorByPercentage(widget.progress / 100),
      ),
    );
  }
}

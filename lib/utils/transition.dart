import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/blocks.dart';
import 'package:flutter_application_1/components/obstacle.dart';
import 'package:flutter_application_1/utils/transition_data.dart';

void transition(
  double distanceToPlayer,
  void Function(Color) updateBackgroundColor,
  void Function(Color) updateBackgroundColorBottom,
  List<Blocks> generatedBlocks,
  List<Obstacle> generatedObstacles,
) {
  double colorProgress = 0;

  for (int i = 0; i < transitionData.length; i++) {
    final transition = transitionData[i];
    final double transitionStart = transition.item1;
    final double transitionEnd = transition.item2;

    if (distanceToPlayer <= transitionStart) {
      colorProgress = 0.0;
      break;
    } else if (distanceToPlayer > transitionStart &&
        distanceToPlayer <= transitionEnd) {
      colorProgress = ((distanceToPlayer - transitionStart) /
              (transitionEnd - transitionStart))
          .clamp(0.0, 1.0);
      break;
    } else if (distanceToPlayer > transitionEnd) {
      colorProgress = 1.0;
      continue;
    }
  }

  Color newColorBack = Colors.transparent;
  Color newColor = Colors.transparent;

  for (int i = 0; i < transitionData.length; i++) {
    final transition = transitionData[i];
    final double transitionStart = transition.item1;
    final double transitionEnd = transition.item2;
    final Color startColor = transition.item3;
    final Color endColor = transition.item4;
    final Color startColorBack = transition.item5;
    final Color endColorBack = transition.item6;

    if (distanceToPlayer < transitionStart) {
      newColorBack = startColorBack;
      newColor = startColor;
      break;
    } else if (distanceToPlayer >= transitionStart &&
        distanceToPlayer <= transitionEnd) {
      newColorBack = Color.lerp(startColorBack, endColorBack, colorProgress)!;
      newColor = Color.lerp(startColor, endColor, colorProgress)!;
      break;
    } else if (distanceToPlayer > transitionEnd) {
      newColorBack = endColorBack;
      newColor = endColor;
    }
  }

  updateBackgroundColor(newColorBack);
  updateBackgroundColorBottom(newColor);

  for (final block in generatedBlocks) {
    block.bluePaintColor = newColor;
  }

  for (final obstacle in generatedObstacles) {
    obstacle.bluePaintColor = newColor;
  }
}

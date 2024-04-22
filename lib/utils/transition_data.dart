import 'package:flutter/material.dart';
import 'package:game/utils/string_to_tuples_list.dart';
import 'package:game/utils/tuples.dart';

List<Tuple6<double, double, Color, Color, Color, Color>> transitionData(
    spawnPointsBlocks) {
  List<Tuple6<double, double, Color, Color, Color, Color>> tuples =
      parseStringToTuple6List(
          spawnPointsBlocks!.properties.getValue('Transition') ??
              "3000, 4000, FF2196F3, FF9C27B0, FF013C6D, FF4A0057");

  return (tuples);
}

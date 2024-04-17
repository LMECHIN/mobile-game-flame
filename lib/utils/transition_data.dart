import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/tuples.dart';

final List<Tuple6<double, double, Color, Color, Color, Color>> transitionData =
    [
  Tuple6(
    3000,
    4000,
    Colors.blue,
    Colors.purple,
    const Color.fromARGB(255, 1, 60, 109),
    const Color.fromARGB(255, 74, 0, 87),
  ),
  Tuple6(
    6000,
    7000,
    Colors.purple,
    Colors.red,
    const Color.fromARGB(255, 74, 0, 87),
    const Color.fromARGB(255, 84, 0, 0),
  ),
  Tuple6(
    8000,
    9000,
    Colors.red,
    Colors.green,
    const Color.fromARGB(255, 84, 0, 0),
    const Color.fromARGB(255, 11, 84, 0),
  ),
];

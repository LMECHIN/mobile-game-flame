
import 'package:flutter/material.dart';
import 'package:game/utils/tuples.dart';

List<Tuple6<double, double, Color, Color, Color, Color>> parseStringToTuple6List(String input) {
  List<String> tuples = input.split(';');

  List<Tuple6<double, double, Color, Color, Color, Color>> resultList = [];

  for (String tupleString in tuples) {
    List<String> items = tupleString.split(',');

    if (items.length < 6) {
      throw Exception('Each tuple in the string must contain at least 6 elements');
    }

    resultList.add(
      Tuple6<double, double, Color, Color, Color, Color>(
        double.parse(items[0].trim()),
        double.parse(items[1].trim()),
        Color(int.parse(items[2].trim(), radix: 16)),
        Color(int.parse(items[3].trim(), radix: 16)),
        Color(int.parse(items[4].trim(), radix: 16)),
        Color(int.parse(items[5].trim(), radix: 16)),
      ),
    );
  }

  return resultList;
}

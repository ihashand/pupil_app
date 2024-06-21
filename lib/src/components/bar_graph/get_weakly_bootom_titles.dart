import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget getWeaklyBootomTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11);

  Widget text;

  switch (value.toInt()) {
    case 0:
      text = const Text(
        'Mon',
        style: style,
      );
      break;
    case 1:
      text = const Text(
        'Tue',
        style: style,
      );
      break;
    case 2:
      text = const Text(
        'Wed',
        style: style,
      );
      break;
    case 3:
      text = const Text(
        'Thu',
        style: style,
      );
      break;
    case 4:
      text = const Text(
        'Fri',
        style: style,
      );
      break;
    case 5:
      text = const Text(
        'Sat',
        style: style,
      );
      break;
    case 6:
      text = const Text(
        'Sun',
        style: style,
      );
      break;
    default:
      text = const Text(
        '',
        style: style,
      );
      break;
  }
  return SideTitleWidget(axisSide: meta.axisSide, child: text);
}

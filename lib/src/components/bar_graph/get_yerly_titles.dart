import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget getYerlyTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11);

  Widget text;

  switch (value.toInt()) {
    case 0:
      text = const Text(
        'Jen',
        style: style,
      );
      break;
    case 1:
      text = const Text(
        'Feb',
        style: style,
      );
      break;
    case 2:
      text = const Text(
        'Mar',
        style: style,
      );
      break;
    case 3:
      text = const Text(
        'Apr',
        style: style,
      );
      break;
    case 4:
      text = const Text(
        'M',
        style: style,
      );
      break;
    case 5:
      text = const Text(
        'Jun',
        style: style,
      );
      break;
    case 6:
      text = const Text(
        'Jul',
        style: style,
      );
    case 7:
      text = const Text(
        'Aug',
        style: style,
      );
    case 8:
      text = const Text(
        'Sep',
        style: style,
      );
    case 9:
      text = const Text(
        'Oct',
        style: style,
      );
    case 10:
      text = const Text(
        'Nov',
        style: style,
      );
    case 11:
      text = const Text(
        'Dec',
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

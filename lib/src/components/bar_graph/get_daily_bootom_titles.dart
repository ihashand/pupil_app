import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget getDailyBootomTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11);

  Widget text;

  int hour = (value).toInt();
  if (hour >= 0 && hour <= 23) {
    text = Text(
      '$hour:00',
      style: style,
    );
  } else {
    text = const Text(
      '',
      style: style,
    );
  }

  return SideTitleWidget(axisSide: meta.axisSide, child: text);
}

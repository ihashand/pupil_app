import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/helpers/days_in_month_helper.dart';

Widget getMonthlyBootomTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11);

  Widget text;

  DateTime now = DateTime.now();
  int daysInMonth = daysInMonthHelper(now.month, now.year);

  int day = value * daysInMonth ~/ 31 + 1;
  if (day <= daysInMonth) {
    text = Text(
      '$day',
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

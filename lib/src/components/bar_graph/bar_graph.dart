import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/bar_graph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List barGraphData; // [sunAmount, monAmount, ... , satAmunt]
  final String selectedTimePeriod; // 'D' - 'W' - 'M' - '6M' - 'Y'
  const MyBarGraph(
      {super.key,
      required this.barGraphData,
      required this.selectedTimePeriod});

  @override
  Widget build(BuildContext context) {
    double maxY = 150.0;
    // initialize bar data
    WeeklyBarData myBarGraphData = WeeklyBarData(
      oneData: barGraphData[0],
      twoData: barGraphData[1],
      threeData: barGraphData[2],
      fourData: barGraphData[3],
      fiveData: barGraphData[4],
      sixData: barGraphData[5],
      sevenData: barGraphData[6],
      eightData: barGraphData[7],
      nineData: barGraphData[8],
      tenData: barGraphData[9],
      elevenData: barGraphData[10],
      twelveData: barGraphData[11],
      thirteenData: barGraphData[12],
      fourteenData: barGraphData[13],
      fifteenData: barGraphData[14],
      sixteenData: barGraphData[15],
      seventeenData: barGraphData[16],
      eighteenData: barGraphData[17],
      nineteenData: barGraphData[18],
      twentyData: barGraphData[19],
      twentyOneData: barGraphData[20],
      twentyTwoData: barGraphData[21],
      twentyThreeData: barGraphData[22],
      twentyFourData: barGraphData[23],
    );

    myBarGraphData.initializeWeeklyBarData(selectedTimePeriod, barGraphData);

    var lenght = 12;
    double bars = 0;
    // daily
    if (selectedTimePeriod == 'D') {
      maxY = 70.0;
      lenght = 24;
      bars = 40;
    }
    // weekly
    if (selectedTimePeriod == 'W') {
      maxY = 80.0;
      lenght = 7;
      bars = 15;
    }
    // monthly
    if (selectedTimePeriod == 'M') {
      maxY = 100.0;
      lenght = 31;
      bars = 30;
    }
    // yearly
    if (selectedTimePeriod == 'Y') {
      maxY = 220.0;
      lenght = 12;
      bars = 20;
    }

    int numberOfBars = barGraphData.length;
    double chartWidth = numberOfBars * bars;

    Widget getBootomTitles(double value, TitleMeta meta) {
      // daily
      if (selectedTimePeriod == 'D') {
        return getDailyBootomTitles(value, meta);
      }
      // weekly
      if (selectedTimePeriod == 'W') {
        return getWeaklyBootomTitles(value, meta);
      }
      // monthly
      if (selectedTimePeriod == 'M') {
        return getMonthlyBootomTitles(value, meta);
      }
      // yearly
      if (selectedTimePeriod == 'Y') {
        return getYerlyTitles(value, meta);
      }
      // default
      return getWeaklyBootomTitles(value, meta);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true, getTitlesWidget: getBootomTitles)),
            ),
            barGroups: generateBarGroups(lenght),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> generateBarGroups(lenght) {
    return List.generate(lenght, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barGraphData[index],
            color: const Color(0xffeb9e5c),
            width: 20, // Adjust bar width to fit your design
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }
}

Widget getWeaklyBootomTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11);

  Widget text;

  switch (value.toInt()) {
    case 0:
      text = const Text(
        'M',
        style: style,
      );
      break;
    case 1:
      text = const Text(
        'T',
        style: style,
      );
      break;
    case 2:
      text = const Text(
        'W',
        style: style,
      );
      break;
    case 3:
      text = const Text(
        'T',
        style: style,
      );
      break;
    case 4:
      text = const Text(
        'F',
        style: style,
      );
      break;
    case 5:
      text = const Text(
        'S',
        style: style,
      );
      break;
    case 6:
      text = const Text(
        'S',
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

// Funkcja zwracająca liczbę dni w miesiącu
int daysInMonthHelper(int month, int year) {
  return DateTime(year, month + 1, 0).day;
}

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

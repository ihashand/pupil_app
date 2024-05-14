import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/bar_graph/bar_data.dart';
import 'package:pet_diary/src/components/bar_graph/get_daily_bootom_titles.dart';
import 'package:pet_diary/src/components/bar_graph/get_monthly_bootom_titles.dart';
import 'package:pet_diary/src/components/bar_graph/get_weakly_bootom_titles.dart';
import 'package:pet_diary/src/components/bar_graph/get_yerly_titles.dart';

class MyBarGraph extends StatelessWidget {
  final List barGraphData; // [sunAmount, monAmount, ... , satAmunt]
  final String selectedTimePeriod; // 'D' - 'W' - 'M' - '6M' - 'Y'
  const MyBarGraph(
      {super.key,
      required this.barGraphData,
      required this.selectedTimePeriod});

  @override
  Widget build(BuildContext context) {
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

    // initalize size of bar
    var lenght = 12;
    double maxY = 150.0;
    double bars = 0;

    // daily
    if (selectedTimePeriod == 'D') {
      maxY = 70.0;
      lenght = 24;
      bars = 40;
    }
    // weekly
    if (selectedTimePeriod == 'W') {
      maxY = 100.0;
      lenght = 7;
      bars = 15;
    }
    // monthly
    if (selectedTimePeriod == 'M') {
      maxY = 150.0;
      lenght = 31;
      bars = 30;
    }
    // yearly
    if (selectedTimePeriod == 'Y') {
      maxY = 200.0;
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
                      showTitles: true,
                      getTitlesWidget: getBootomTitles,
                      reservedSize: 30)),
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
            width: 20,
            borderRadius: BorderRadius.circular(5),
          )
        ],
      );
    });
  }
}

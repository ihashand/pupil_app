import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Line Chart'),
      ),
      body: Column(
        children: [
          // Options for selecting Week, Month, or Year
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle Week button press
                  // You can add your logic here
                },
                child: Text('Week'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle Month button press
                  // You can add your logic here
                },
                child: Text('Month'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle Year button press
                  // You can add your logic here
                },
                child: Text('Year'),
              ),
            ],
          ),
          Container(
            height: 300, // Specify a finite height for the container
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles:
                        SideTitles(showTitles: false), // Hide left titles
                    topTitles: SideTitles(showTitles: false), // Hide top titles
                    rightTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff7589a2),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return '0 ';
                          case 5:
                            return '5 ';
                          case 10:
                            return '10 ';
                          case 15:
                            return '15 ';
                          case 20:
                            return '20 ';
                        }
                        return '';
                      },
                      interval: 5,
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff7589a2),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Pon';
                          case 1:
                            return 'Wt';
                          case 2:
                            return 'Śr';
                          case 3:
                            return 'Czw';
                          case 4:
                            return 'Pt';
                          case 5:
                            return 'Sob';
                          case 6:
                            return 'Niedz';
                        }
                        return '';
                      },
                      interval: 1,
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 20,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 1),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      colors: [Colors.blue],
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle the "Add Weight" button press
              // You can add your logic here
            },
            child: Text('Add Weight'),
          ),
        ],
      ),
    );
  }
}

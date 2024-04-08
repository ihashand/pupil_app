import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/water_model.dart';

class PetDetailWaterWidget extends StatelessWidget {
  const PetDetailWaterWidget({
    super.key,
    required this.buttonColor,
    required this.textSecondSectionColor,
    required this.water,
    required this.lastTenWaters,
    required this.diagramFirst,
    required this.diagramSecond,
  });

  final Color buttonColor;
  final Color textSecondSectionColor;
  final String water;
  final List<Water> lastTenWaters;
  final Color diagramFirst;
  final Color diagramSecond;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: 140,
        height: 110,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '💧',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        'Water drinked',
                        style: TextStyle(
                            fontSize: 11, color: textSecondSectionColor),
                      ),
                      Text(
                        water,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textSecondSectionColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (lastTenWaters.isNotEmpty)
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          lastTenWaters.map((water) => water.water).reduce(max),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                      gridData: const FlGridData(
                        show: false,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: lastTenWaters.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.water,
                              gradient: LinearGradient(
                                colors: [diagramFirst, diagramSecond],
                                // ignore: prefer_const_literals_to_create_immutables
                                stops: [0.5, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 350),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              if (lastTenWaters.isEmpty)
                Text(
                  'No water drinked yet',
                  style: TextStyle(fontSize: 12, color: textSecondSectionColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

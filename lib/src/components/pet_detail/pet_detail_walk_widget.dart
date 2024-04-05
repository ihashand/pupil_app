import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/walk_model.dart';

class PetDetailWalkWidget extends ConsumerWidget {
  const PetDetailWalkWidget({
    super.key,
    required this.rectangleColor,
    required this.textSecondSectionColor,
    required this.walk,
    required this.lastTenWalks,
    required this.diagramFirst,
    required this.diagramSecond,
  });

  final Color rectangleColor;
  final Color textSecondSectionColor;
  final String walk;
  final List<Walk> lastTenWalks;
  final Color diagramFirst;
  final Color diagramSecond;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: SizedBox(
        width: 180,
        height: 130,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: rectangleColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '🚶',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        'Walk distance',
                        style: TextStyle(
                            fontSize: 11, color: textSecondSectionColor),
                      ),
                      Text(
                        walk,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textSecondSectionColor),
                      ),
                    ],
                  ),
                ],
              ),
              if (lastTenWalks.isNotEmpty)
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: lastTenWalks
                          .map((walk) => walk.walkDistance)
                          .reduce(max),
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                      gridData: const FlGridData(
                        show: false,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: lastTenWalks.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.walkDistance,
                              gradient: LinearGradient(
                                colors: [
                                  diagramFirst,
                                  diagramSecond,
                                ],
                                stops: const [0.5, 1.0],
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
              if (lastTenWalks.isEmpty)
                Text(
                  'No walks yet',
                  style: TextStyle(fontSize: 12, color: textSecondSectionColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

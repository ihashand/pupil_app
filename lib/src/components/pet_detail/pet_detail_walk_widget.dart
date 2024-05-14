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
    this.textPadding = const EdgeInsets.only(left: 5), // Default padding
  });

  final Color rectangleColor;
  final Color textSecondSectionColor;
  final String walk;
  final List<Walk?> lastTenWalks;
  final Color diagramFirst;
  final Color diagramSecond;
  final EdgeInsets textPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: SizedBox(
        width: 140,
        height: 110,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: rectangleColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the start
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🚶',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: textPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ],
              ),
              if (lastTenWalks.isNotEmpty)
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: lastTenWalks
                          .map((walk) => walk!.distance)
                          .reduce(max),
                      titlesData: const FlTitlesData(show: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: lastTenWalks.asMap().entries.map((entry) {
                        double barWidthFactor =
                            (lastTenWalks.length <= 3) ? 0.6 : 0.15;
                        return BarChartGroupData(
                          x: entry.key,
                          barsSpace: barWidthFactor,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value!.distance,
                              gradient: LinearGradient(
                                colors: [diagramFirst, diagramSecond],
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
              const SizedBox(height: 10),
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

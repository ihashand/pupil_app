import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/bar_graph/bar_graph.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_daily_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_monthly_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_weekly_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_yearly_walks.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/screens/health_walk_all_data_screen.dart';
import '../helper/calculate_average.dart';

class HealthWalkScreen extends ConsumerStatefulWidget {
  const HealthWalkScreen(this.petId, this.petEvents, {super.key});
  final String petId;
  final List<Event> petEvents;

  @override
  createState() => _HealthWalkScreenState();
}

class _HealthWalkScreenState extends ConsumerState<HealthWalkScreen> {
  DateTime selectedDateTime = DateTime.now();
  String selectedTimePeriod = 'W';
  List<double> graphBarData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 14),
        title: Text(
          'A C T I V I T Y',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 40,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer(builder: (context, ref, _) {
            final asyncWalks = ref.watch(eventWalksProvider);

            return asyncWalks.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error fetching walks: $err'),
              data: (walks) {
                List<EventWalkModel?> petWalks =
                    walks.where((walk) => walk!.petId == widget.petId).toList();

                switch (selectedTimePeriod) {
                  case 'D':
                    graphBarData = calculateDailyWalks(petWalks);
                    break;
                  case 'W':
                    graphBarData = calculateWeeklyWalks(petWalks);
                    break;
                  case 'M':
                    graphBarData = calculateMonthlyWalks(petWalks);
                    break;
                  case 'Y':
                    graphBarData = calculateYearlyWalks(petWalks);
                    break;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['D', 'W', 'M', 'Y']
                              .map((label) =>
                                  _buildTimePeriodButton(label, context))
                              .toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: SizedBox(
                          height: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: MyBarGraph(
                              barGraphData: graphBarData,
                              selectedTimePeriod: selectedTimePeriod,
                            ),
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          right: 230, bottom: 12, top: 10),
                      child: Text(
                        'Average : ${calculateAverage(graphBarData).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 250.0, left: 20, right: 20),
                      child: SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HealthWalkAllDataScreen(
                                  widget.petId, widget.petEvents),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'All data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButton(String label, BuildContext context) {
    String fullLabel;
    switch (label) {
      case 'D':
        fullLabel = selectedTimePeriod == 'D' ? 'Day' : 'D';
        break;
      case 'W':
        fullLabel = selectedTimePeriod == 'W' ? 'Week' : 'W';
        break;
      case 'M':
        fullLabel = selectedTimePeriod == 'M' ? 'Month' : 'M';
        break;
      case 'Y':
        fullLabel = selectedTimePeriod == 'Y' ? 'Year' : 'Y';
        break;
      default:
        fullLabel = label;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: TextButton(
        key: ValueKey<String>(fullLabel),
        onPressed: () {
          setState(() {
            selectedTimePeriod = label;
          });
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          fullLabel,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedTimePeriod == label
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

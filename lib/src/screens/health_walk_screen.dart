import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/bar_graph/bar_graph.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_daily_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_monthly_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_weekly_walks.dart';
import 'package:pet_diary/src/components/bar_graph/walks_bar_graph/calculate_yearly_walks.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import '../helper/calculate_average.dart';
import 'all_data_walk_screen.dart';

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
        title: const Text('Walks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: StreamBuilder<List<Walk?>>(
                stream: ref.read(walkServiceProvider).getWalksStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error fetching walks: ${snapshot.error}');
                  }

                  if (snapshot.hasData) {
                    List<Walk?> walks = snapshot.data!
                        .where((walk) => walk!.petId == widget.petId)
                        .toList();

                    switch (selectedTimePeriod) {
                      case 'D':
                        graphBarData = calculateDailyWalks(walks);
                        break;
                      case 'W':
                        graphBarData = calculateWeeklyWalks(walks);
                        break;
                      case 'M':
                        graphBarData = calculateMonthlyWalks(walks);
                        break;
                      case 'Y':
                        graphBarData = calculateYearlyWalks(walks);
                        break;
                    }

                    return Column(
                      children: [
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
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 50,
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
                              top: 15.0, left: 15, right: 15),
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
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 250.0, left: 20, right: 20),
                          child: SizedBox(
                            width: 350,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AllDataWalkScreen(
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
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButton(String label, BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedTimePeriod = label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedTimePeriod == label
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/health_activity_widgets/average_section.dart';
import 'package:pet_diary/src/components/health_activity_widgets/day_view.dart';
import 'package:pet_diary/src/components/report_widget/generate_report_card.dart';
import 'package:pet_diary/src/components/health_activity_widgets/month_view.dart';
import 'package:pet_diary/src/components/health_activity_widgets/popup.dart';
import 'package:pet_diary/src/components/health_activity_widgets/section_title.dart';
import 'package:pet_diary/src/components/health_activity_widgets/summary_section.dart';
import 'package:pet_diary/src/components/health_activity_widgets/switch_widget.dart';
import 'package:pet_diary/src/components/health_activity_widgets/week_view.dart';

class HealthActivityScreen extends ConsumerStatefulWidget {
  final String petId;
  const HealthActivityScreen(this.petId, {super.key});

  @override
  createState() => _HealthActivityScreenState();
}

class _HealthActivityScreenState extends ConsumerState<HealthActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String selectedView = 'M';
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double arrowButtonSize = 14.0;
  late AnimationController _animationController;
  late Animation<double> _popupAnimation;
  DateTime? _lastSelectedDay;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isAppBarVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;
      });
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _popupAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: true,
              pinned: true,
              snap: true,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColorDark,
              ),
              title: AnimatedOpacity(
                opacity: _isAppBarVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'A C T I V I T Y',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              toolbarHeight: 50,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).primaryColorDark,
                    size: 24,
                  ),
                  onPressed: () {
                    // Dodaj logikę dla menu
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64.0),
                child: SwitchWidget(
                  selectedView: selectedView,
                  onSelectedViewChanged: (view) {
                    setState(() {
                      selectedView = view;
                      _animationController.forward(from: 0);
                      if (view == 'M' || view == 'W') {
                        selectedDate = DateTime.now();
                      }
                      _lastSelectedDay = null;
                    });
                  },
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedView == 'D')
                      DayView(
                        selectedDate: selectedDate,
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      )
                    else if (selectedView == 'W')
                      Column(
                        children: [
                          WeekView(
                            selectedDate: selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            onDaySelected: (day) {
                              setState(() {
                                if (_lastSelectedDay == day) {
                                  _lastSelectedDay = null;
                                } else {
                                  selectedDate = day;
                                  _lastSelectedDay = day;
                                  _animationController.forward(from: 0);
                                }
                              });
                            },
                            lastSelectedDay: _lastSelectedDay,
                          ),
                          if (_lastSelectedDay != null)
                            SizeTransition(
                              sizeFactor: _popupAnimation,
                              child: Popup(
                                selectedDate: selectedDate,
                                petId: widget.petId,
                                onSelectedViewChanged: (view) {
                                  setState(() {
                                    selectedView = 'D';
                                    selectedDate = _lastSelectedDay!;
                                    _lastSelectedDay = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          MonthView(
                            selectedDate: selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            onDaySelected: (day) {
                              setState(() {
                                if (_lastSelectedDay == day) {
                                  _lastSelectedDay = null;
                                } else {
                                  selectedDate = day;
                                  _lastSelectedDay = day;
                                  _animationController.forward(from: 0);
                                }
                              });
                            },
                            lastSelectedDay: _lastSelectedDay,
                          ),
                          if (_lastSelectedDay != null)
                            SizeTransition(
                              sizeFactor: _popupAnimation,
                              child: Popup(
                                selectedDate: selectedDate,
                                petId: widget.petId,
                                onSelectedViewChanged: (view) {
                                  setState(() {
                                    selectedView = 'D';
                                    selectedDate = _lastSelectedDay!;
                                    _lastSelectedDay = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SectionTitle(title: "Summary"),
                    SummarySection(
                      selectedView: selectedView,
                      selectedDate: selectedDate,
                      petId: widget.petId,
                    ),
                    if (selectedView != 'D') ...[
                      const SectionTitle(title: "Average"),
                      AverageSection(
                        selectedView: selectedView,
                        selectedDate: selectedDate,
                        petId: widget.petId,
                      ),
                    ],
                    const SectionTitle(title: "Generate Report"),
                    GenerateReportCard(
                      petId: widget.petId,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

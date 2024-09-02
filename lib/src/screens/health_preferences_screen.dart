import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_preferences.dart';
import 'package:pet_diary/src/providers/event_preferences_provider.dart';

class HealthPreferencesScreen extends ConsumerStatefulWidget {
  final String petId;

  const HealthPreferencesScreen({super.key, required this.petId});

  @override
  HealthPreferencesScreenState createState() => HealthPreferencesScreenState();
}

class HealthPreferencesScreenState
    extends ConsumerState<HealthPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late List<String> sectionOrder;
  late List<String> visibleSections;
  bool showInfo = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, String> sectionIcons = {
    'Lifestyle': '🚶',
    'Care': '🛁',
    'Services': '🛠️',
    'Psychic': '🧠',
    'Stool': '💩',
    'Urine': '💧',
    'Mood': '😊',
    'Stomach': '🤢',
    'Notes': '📝',
    'Meds': '💊',
    'Vaccin': '💉',
  };

  @override
  void initState() {
    super.initState();
    final preferences = ref.read(preferencesProvider);
    sectionOrder = List.from(preferences.sectionOrder);
    visibleSections = List.from(preferences.visibleSections);

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the animation
    _controller.forward();

    // Hide the info message after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _controller.reverse().then((value) {
          if (mounted) {
            setState(() {
              showInfo = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'C O N F I G U R E   S E C T I O N S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Theme.of(context).primaryColorDark,
              size: 20,
            ),
            onPressed: () {
              ref.read(preferencesProvider.notifier).updatePreferences(
                    PreferencesModel(
                      sectionOrder: sectionOrder,
                      visibleSections: visibleSections,
                    ),
                  );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
        ),
      ),
      body: Column(
        children: [
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Text(
                'Reorder sections by dragging',
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: sectionOrder.isEmpty
                ? Center(
                    child: Text(
                      'No sections available to configure.',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                  )
                : ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = sectionOrder.removeAt(oldIndex);
                        sectionOrder.insert(newIndex, item);
                      });
                    },
                    children: sectionOrder.map((section) {
                      final bool isSelected = visibleSections.contains(section);
                      return GestureDetector(
                        key: ValueKey(section),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              visibleSections.remove(section);
                            } else {
                              visibleSections.add(section);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 3.5, bottom: 3.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Text(
                                sectionIcons[section] ?? '❓',
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(section),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColorDark,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_preferences.dart';
import 'package:pet_diary/src/providers/event_preferences_provider.dart';

class PreferencesDialog extends ConsumerStatefulWidget {
  final String petId;

  const PreferencesDialog({super.key, required this.petId});

  @override
  PreferencesDialogState createState() => PreferencesDialogState();
}

class PreferencesDialogState extends ConsumerState<PreferencesDialog> {
  late List<String> sectionOrder;
  late List<String> visibleSections;

  final Map<String, String> sectionIcons = {
    'Lifestyle': '🚶',
    'Care': '🛁',
    'Services': '🛠️',
    'Psychic Issues': '🧠',
    'Stool Type': '💩',
    'Urine Color': '💧',
    'Mood': '😊',
    'Stomach Issues': '🤢',
    'Notes': '📝',
    'Meds': '💊',
  };

  @override
  void initState() {
    super.initState();
    final preferences = ref.read(preferencesProvider);
    sectionOrder = List.from(preferences.sectionOrder);
    visibleSections = List.from(preferences.visibleSections);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      title: const Text('Configure Sections'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.53,
        child: sectionOrder.isEmpty
            ? Center(
                child: Text(
                  'No sections available to configure.',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Text(sectionIcons[section] ?? '❓',
                            style: const TextStyle(fontSize: 24)),
                        title: Text(section),
                        trailing: isSelected
                            ? Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).primaryColorDark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('OK',
              style: TextStyle(color: Theme.of(context).primaryColorDark)),
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
    );
  }
}

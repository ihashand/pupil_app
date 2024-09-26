import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/event_care/event_type_card_care.dart';
import 'package:pet_diary/src/components/events/event_food/others/event_type_card_food.dart';
import 'package:pet_diary/src/components/events/event_issue/event_type_card_issue.dart';
import 'package:pet_diary/src/components/events/event_medications/event_type_card_medicine.dart';
import 'package:pet_diary/src/components/events/event_mood/event_type_card_mood.dart';
import 'package:pet_diary/src/components/events/event_notes/event_type_card_notes.dart';
import 'package:pet_diary/src/components/events/event_stool/event_type_card_stool.dart';
import 'package:pet_diary/src/components/events/event_temperature/event_type_card_temperature.dart';
import 'package:pet_diary/src/components/events/event_urine/event_type_card_urine.dart';
import 'package:pet_diary/src/components/events/event_vaccines/event_type_card_vaccine.dart';
import 'package:pet_diary/src/components/events/event_water/event_type_card_water.dart';
import 'package:pet_diary/src/components/events/event_weight/event_type_card_weight.dart';
import 'package:pet_diary/src/components/events/walk/event_type_card_walk.dart';
import 'package:pet_diary/src/services/events_services/event_type_service.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:math';

class EventTypeSelectionScreen extends ConsumerStatefulWidget {
  final String petId;

  const EventTypeSelectionScreen({super.key, required this.petId});

  @override
  createState() => _EventTypeSelectionState();
}

class _EventTypeSelectionState extends ConsumerState<EventTypeSelectionScreen>
    with TickerProviderStateMixin {
  bool isEditMode = false;
  List<Map<String, dynamic>> eventTypeCards = [];
  final List<AnimationController> _animationControllers = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  late TextEditingController titleController;
  late TextEditingController contentTextController;
  late TextEditingController temperatureController;
  late TextEditingController dateController;
  final EventTypeService _eventTypeService = EventTypeService();

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();

    titleController = TextEditingController();
    contentTextController = TextEditingController();
    temperatureController = TextEditingController();
    dateController = TextEditingController();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    titleController.dispose();
    contentTextController.dispose();
    temperatureController.dispose();
    dateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<String> getDefaultKeywords(String widgetName) {
    switch (widgetName) {
      case 'eventTypeCardWater':
        return [
          'water',
          'hydration',
          'fluid intake',
          'thirst',
          'wellness',
          'health',
          'refreshment'
        ];
      case 'eventTypeCardFood':
        return [
          'food',
          'nutrition',
          'diet',
          'meals',
          'feeding',
          'health',
          'wellbeing'
        ];
      case 'eventTypeCardMedicine':
        return [
          'medicine',
          'medication',
          'treatment',
          'prescription',
          'healthcare',
          'wellness',
          'therapy'
        ];
      case 'eventTypeCardVaccines':
        return [
          'vaccines',
          'health',
          'immunization',
          'protection',
          'prevention',
          'wellness',
          'safety'
        ];
      case 'eventTypeCardMood':
        return ['mood', 'heart', 'love', 'sad', 'cry', 'emotions', 'feelings'];
      case 'eventTypeCardIssues':
        return [
          'issues',
          'problems',
          'concerns',
          'health',
          'behavior',
          'symptoms',
          'troubles'
        ];
      case 'eventTypeCardCare':
        return [
          'care',
          'grooming',
          'maintenance',
          'hygiene',
          'wellness',
          'support',
          'attention'
        ];
      case 'eventTypeCardStool':
        return [
          'stool',
          'bowel',
          'digestion',
          'health',
          'wellness',
          'monitoring',
          'excretion'
        ];
      case 'eventTypeCardUrine':
        return [
          'urine',
          'pee',
          'water',
          'hydration',
          'health',
          'monitoring',
          'excretion'
        ];
      case 'eventTypeCardWeight':
        return [
          'weight',
          'mass',
          'measurement',
          'health',
          'wellness',
          'tracking',
          'fitness'
        ];
      case 'eventTypeCardTemperature':
        return [
          'temperature',
          'heat',
          'body temperature',
          'health',
          'monitoring',
          'wellness',
          'fever'
        ];
      case 'eventTypeCardWalk':
        return ['walk'];
      case 'eventTypeCardNotes':
        return [
          'notes',
          'journal',
          'records',
          'observations',
          'tracking',
          'information',
          'documentation'
        ];
      default:
        return [];
    }
  }

  Future<void> _loadUserPreferences() async {
    DocumentSnapshot doc =
        await _eventTypeService.getUserEventTypePreferences();

    if (doc.exists) {
      setState(() {
        eventTypeCards = List<Map<String, dynamic>>.from(doc['eventTypeCards']);
        for (var card in eventTypeCards) {
          if (!card.containsKey('keywords')) {
            card['keywords'] = getDefaultKeywords(card['widget']);
          }
        }
      });
    } else {
      eventTypeCards = [
        {
          'widget': 'eventTypeCardWater',
          'isActive': true,
          'keywords': [
            'water',
            'hydration',
            'fluid intake',
            'thirst',
            'wellness',
            'health',
            'refreshment'
          ]
        },
        {
          'widget': 'eventTypeCardFood',
          'isActive': true,
          'keywords': [
            'food',
            'nutrition',
            'diet',
            'meals',
            'feeding',
            'health',
            'wellbeing'
          ]
        },
        {
          'widget': 'eventTypeCardMedicine',
          'isActive': true,
          'keywords': [
            'medicine',
            'medication',
            'treatment',
            'prescription',
            'healthcare',
            'wellness',
            'therapy'
          ]
        },
        {
          'widget': 'eventTypeCardVaccines',
          'isActive': true,
          'keywords': [
            'vaccines',
            'health',
            'immunization',
            'protection',
            'prevention',
            'wellness',
            'safety'
          ]
        },
        {
          'widget': 'eventTypeCardMood',
          'isActive': true,
          'keywords': [
            'mood',
            'heart',
            'love',
            'sad',
            'cry',
            'emotions',
            'feelings'
          ]
        },
        {
          'widget': 'eventTypeCardIssues',
          'isActive': true,
          'keywords': [
            'issues',
            'problems',
            'concerns',
            'health',
            'behavior',
            'symptoms',
            'troubles'
          ]
        },
        {
          'widget': 'eventTypeCardCare',
          'isActive': true,
          'keywords': [
            'care',
            'grooming',
            'maintenance',
            'hygiene',
            'wellness',
            'support',
            'attention'
          ]
        },
        {
          'widget': 'eventTypeCardStool',
          'isActive': true,
          'keywords': [
            'stool',
            'bowel',
            'digestion',
            'health',
            'wellness',
            'monitoring',
            'excretion'
          ]
        },
        {
          'widget': 'eventTypeCardUrine',
          'isActive': true,
          'keywords': [
            'urine',
            'pee',
            'water',
            'hydration',
            'health',
            'monitoring',
            'excretion'
          ]
        },
        {
          'widget': 'eventTypeCardWeight',
          'isActive': true,
          'keywords': [
            'weight',
            'mass',
            'measurement',
            'health',
            'wellness',
            'tracking',
            'fitness'
          ]
        },
        {
          'widget': 'eventTypeCardTemperature',
          'isActive': true,
          'keywords': [
            'temperature',
            'heat',
            'body temperature',
            'health',
            'monitoring',
            'wellness',
            'fever'
          ]
        },
        {
          'widget': 'eventTypeCardWalk',
          'isActive': true,
          'keywords': [
            'walk',
          ]
        },
        {
          'widget': 'eventTypeCardNotes',
          'isActive': true,
          'keywords': [
            'notes',
            'journal',
            'records',
            'observations',
            'tracking',
            'information',
            'documentation'
          ]
        }
      ];
    }

    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    _animationControllers.clear();
    for (int i = 0; i < eventTypeCards.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + Random().nextInt(2000)),
      )..repeat(reverse: true);
      _animationControllers.add(controller);
    }
  }

  Future<void> _saveUserPreferences() async {
    List<Map<String, dynamic>> activeCards =
        eventTypeCards.where((card) => card['isActive']).toList();
    List<Map<String, dynamic>> inactiveCards =
        eventTypeCards.where((card) => !card['isActive']).toList();
    eventTypeCards = [...activeCards, ...inactiveCards];

    await _eventTypeService.saveUserEventTypePreferences(eventTypeCards);
  }

  void _toggleEditMode() {
    setState(() {
      if (isEditMode) {
        _saveUserPreferences();
      }
      isEditMode = !isEditMode;
    });
  }

  void _toggleCardVisibility(int index) {
    int activeCount =
        eventTypeCards.where((card) => card['isActive'] == true).length;
    if (activeCount <= 1 && eventTypeCards[index]['isActive']) {
      return;
    }

    setState(() {
      eventTypeCards[index]['isActive'] = !eventTypeCards[index]['isActive'];
    });
  }

  Widget _buildCard(String widgetName) {
    switch (widgetName) {
      case 'eventTypeCardWater':
        return eventTypeCardWater(context, ref, widget.petId);
      case 'eventTypeCardFood':
        return eventTypeCardFood(context, ref, widget.petId);
      case 'eventTypeCardMedicine':
        return eventTypeCardMedicine(context, ref, widget.petId);
      case 'eventTypeCardVaccines':
        return eventTypeCardVaccines(context, ref, widget.petId);
      case 'eventTypeCardMood':
        return eventTypeCardMood(context, ref, widget.petId, dateController);
      case 'eventTypeCardIssues':
        return eventTypeCardIssues(context, ref, widget.petId, dateController);
      case 'eventTypeCardCare':
        return eventTypeCardCare(context, ref, widget.petId, dateController);
      case 'eventTypeCardStool':
        return eventTypeCardStool(context, ref, widget.petId);
      case 'eventTypeCardUrine':
        return eventTypeCardUrine(context, ref, widget.petId);
      case 'eventTypeCardWeight':
        return eventTypeCardWeight(context, ref, widget.petId);
      case 'eventTypeCardTemperature':
        return eventTypeCardTemperature(
            context, temperatureController, ref, widget.petId);
      case 'eventTypeCardNotes':
        return eventTypeCardNotes(
            context, titleController, contentTextController, ref, widget.petId);
      case 'eventTypeCardWalk':
        return eventTypeCardWalk(context, ref, widget.petId);
      default:
        return const SizedBox.shrink(); // Sprawdzamy, czy są zwracane widgety
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width / 2 - 36;

    List<Widget> cardWidgets = [];
    for (int i = 0; i < eventTypeCards.length; i++) {
      if ((isEditMode || eventTypeCards[i]['isActive']) &&
          (searchQuery.isEmpty ||
              (eventTypeCards[i]['keywords'] != null &&
                  (eventTypeCards[i]['keywords'] as List<dynamic>).any(
                      (keyword) => keyword
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery))))) {
        Widget card = GestureDetector(
          key: ValueKey(i),
          onTap: isEditMode ? () => _toggleCardVisibility(i) : null,
          child: SizedBox(
            width: cardWidth,
            height: 205,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _animationControllers[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: isEditMode
                          ? Offset(
                              sin(_animationControllers[i].value * 2 * pi) * 2,
                              0,
                            )
                          : Offset.zero,
                      child: child,
                    );
                  },
                  child: Opacity(
                    opacity: eventTypeCards[i]['isActive'] ? 1.0 : 0.5,
                    child: _buildCard(eventTypeCards[i]['widget']),
                  ),
                ),
                if (isEditMode)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        eventTypeCards[i]['isActive']
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: eventTypeCards[i]['isActive']
                            ? Colors.green
                            : Colors.red,
                      ),
                      onPressed: () => _toggleCardVisibility(i),
                    ),
                  ),
              ],
            ),
          ),
        );

        cardWidgets.add(card);
      }
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        title: Text(
          isEditMode ? 'E D I T' : 'E V E N T S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(
              isEditMode ? Icons.save : Icons.edit,
              color: Theme.of(context).primaryColorDark,
              size: 24,
            ),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Divider(color: Theme.of(context).colorScheme.surface),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).primaryColorDark),
                      border: InputBorder.none,
                      fillColor: Theme.of(context).colorScheme.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.all(10.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isEditMode
                ? SingleChildScrollView(
                    child: Center(
                      child: ReorderableWrap(
                        maxMainAxisCount: 2,
                        spacing: 10.0,
                        runSpacing: 10.0,
                        padding: const EdgeInsets.all(10),
                        needsLongPressDraggable: false,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = eventTypeCards.removeAt(oldIndex);
                            eventTypeCards.insert(newIndex, item);

                            final controller =
                                _animationControllers.removeAt(oldIndex);
                            _animationControllers.insert(newIndex, controller);
                          });
                        },
                        children: cardWidgets,
                      ),
                    ),
                  )
                : GridView.count(
                    padding: const EdgeInsets.all(10),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: cardWidth / 180,
                    children: cardWidgets,
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/events/walk_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/my_button_widget.dart';
import '../models/events_icons_module_model.dart';
import 'weight_screen.dart';

class NewEventScreen extends ConsumerWidget {
  BuildContext context;
  TextEditingController nameController;
  TextEditingController descriptionController;
  DateTime dateController;
  WidgetRef ref;
  List<Event>? allEvents;
  void Function(DateTime date, DateTime focusedDate) selectDate;

  NewEventScreen(this.context, this.nameController, this.descriptionController,
      this.dateController, this.ref, this.allEvents, this.selectDate,
      {super.key, Key? anotherKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = createModules(context, nameController,
        descriptionController, dateController, ref, allEvents!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return Container(
            margin: module.margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: module.moduleColor,
                    borderRadius: BorderRadius.circular(module.borderRadius),
                  ),
                  padding: module.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        module.name,
                        style: TextStyle(
                          fontSize: module.fontSize,
                          fontFamily: module.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                        itemCount: module.icons.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, iconIndex) {
                          final icon = module.icons[iconIndex];
                          return Center(
                            child: icon,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

List<EventsIconsModule> createModules(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController descriptionController,
  DateTime dateController,
  WidgetRef ref,
  List<Event> allEvents,
) {
  final module_1 = EventsIconsModule(
    name: 'L I F E  S T Y L E',
    icons: [
      MyButtonWidget(
        iconData: FontAwesomeIcons.walking,
        label: 'W A L K',
        onTap: () {
          walkEvent(context, nameController, descriptionController,
              dateController, ref, allEvents, (date, focusedDate) {}, 0, 0);
        },
        color: const Color.fromARGB(255, 103, 146, 167),
        opacity: 0.6,
        borderRadius: 20.0,
        iconSize: 14.0,
        fontSize: 10.0,
        fontFamily: 'San Francisco',
      ),
      MyButtonWidget(
        iconData: FontAwesomeIcons.weightScale,
        label: 'W E I G H T',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WeightScreen(),
            ),
          );
        },
        color: const Color.fromARGB(255, 103, 146, 167),
        opacity: 0.6,
        borderRadius: 20.0,
        iconSize: 14.0,
        fontSize: 10.0,
        fontFamily: 'San Francisco',
      ),
    ],
    moduleColor: const Color.fromARGB(255, 182, 182, 182),
    padding: const EdgeInsets.all(8.0),
    borderRadius: 15.0,
    fontSize: 13.0,
    fontFamily: 'San Francisco',
    margin: const EdgeInsets.all(8.0),
  );

  return [module_1];
}

import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_icons_module.dart';

class EventModules extends StatelessWidget {
  const EventModules({
    super.key,
    required this.modules,
  });

  final List<EventsIconsModule> modules;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: modules.map((module) {
          return Container(
            margin: module.margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: module.moduleColor,
                    borderRadius: BorderRadius.circular(module.borderRadius),
                  ),
                  padding: module.padding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 5),
                      ...module.items.map((item) {
                        // Renderowanie ikony
                        return item.content;
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

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
                  height: 130,
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
        }).toList(),
      ),
    );
  }
}

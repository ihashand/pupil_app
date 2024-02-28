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
                  margin: const EdgeInsets.symmetric(
                      vertical: 5), // Add vertical margin
                  height: module.icons.length > 1 ? 140 : 160,
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
                      const SizedBox(
                        height: 5,
                      ),
                      if (module.icons.length == 1)
                        SizedBox(
                          height: 100,
                          width: 400,
                          child: module.icons.first,
                        ),
                      if (module.icons.length > 1)
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: module.icons.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, iconIndex) {
                              final icon = module.icons[iconIndex];
                              return AspectRatio(
                                aspectRatio: 2,
                                child: Center(
                                  child: SizedBox(
                                    height: 150,
                                    width: 100,
                                    child: icon,
                                  ),
                                ),
                              );
                            },
                          ),
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

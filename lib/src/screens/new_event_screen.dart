import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/modules_provider.dart';

class NewEventScreen extends ConsumerWidget {
  const NewEventScreen({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

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

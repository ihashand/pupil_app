import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class NamePillDetails extends ConsumerWidget {
  const NamePillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(2),
        child: InputDecorator(
          decoration: const InputDecoration(
            fillColor: Colors.black,
            labelText: 'Name',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
              fontSize: 20,
            ),
          ),
          child: TextFormField(
            controller: ref.read(pillNameControllerProvider),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

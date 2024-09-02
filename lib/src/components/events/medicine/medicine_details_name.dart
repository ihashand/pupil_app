import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';

class MedicinieDetailsName extends ConsumerWidget {
  const MedicinieDetailsName({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(2),
      child: InputDecorator(
        decoration: const InputDecoration(
          fillColor: Colors.black,
          labelText: 'Name',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(fontSize: 16),
        ),
        child: TextFormField(
          controller: ref.read(eventMedicineNameControllerProvider),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
    );
  }
}

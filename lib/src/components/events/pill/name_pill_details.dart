// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class NamePillDetails extends ConsumerWidget {
  const NamePillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 60,
      child: InputDecorator(
        decoration: const InputDecoration(
          fillColor: Colors.black,
          labelText: 'N a m e',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            fontSize: 16, // Ustaw rozmiar czcionki dla tekstu etykiety
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
    );
  }
}

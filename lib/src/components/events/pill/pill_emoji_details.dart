// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class EmojiPillDetails extends ConsumerWidget {
  const EmojiPillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 60,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'E m o j i',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            fontSize: 16, // Ustaw rozmiar czcionki dla tekstu etykiety
          ),
        ),
        child: TextFormField(
          controller: ref.read(pillEmojiProvider),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter emoji or one letter';
            }
            return null;
          },
        ),
      ),
    );
  }
}

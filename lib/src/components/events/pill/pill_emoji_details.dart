import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class EmojiPillDetails extends ConsumerWidget {
  const EmojiPillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
        child: SizedBox(
      height: 70,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Emoji',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            fontSize: 20,
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
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/event_medicine_provider.dart';

class MedicineDetailsEmoji extends ConsumerStatefulWidget {
  final Function(bool) onShowMoreChanged;

  const MedicineDetailsEmoji({super.key, required this.onShowMoreChanged});

  @override
  createState() => _EmojiPillDetailsState();
}

class _EmojiPillDetailsState extends ConsumerState<MedicineDetailsEmoji> {
  final List<String> emojis = [
    '💊',
    '💉',
    '🩺',
    '💧',
    '🌡️',
    '⚕️',
    '🩹',
    '🩸',
    '🧬',
    '⚖️',
    '🔬',
    '👨‍⚕️',
    '👩‍⚕️',
    '🍖',
    '🧫'
  ];
  late String selectedEmoji;
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    selectedEmoji = ref.read(eventMedicineEmojiProvider).text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emoji',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    showMore = !showMore;
                    widget.onShowMoreChanged(showMore);
                  });
                },
                child: Text(
                  showMore ? 'Show less' : 'Show more',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (showMore ? emojis : emojis.take(5)).map((emoji) {
              bool isSelected = emoji == selectedEmoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmoji = emoji;
                    ref.read(eventMedicineEmojiProvider).text = emoji;
                  });
                },
                child: CircleAvatar(
                  radius: 29,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.inversePrimary,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 22,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

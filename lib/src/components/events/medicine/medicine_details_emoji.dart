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
    '🩻',
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
      padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Icons',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 25,
            runSpacing: 15,
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
                  radius: 20,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
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

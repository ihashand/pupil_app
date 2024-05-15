import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class EmojiPillDetails extends ConsumerStatefulWidget {
  final Function(bool) onShowMoreChanged;

  const EmojiPillDetails({super.key, required this.onShowMoreChanged});

  @override
  createState() => _EmojiPillDetailsState();
}

class _EmojiPillDetailsState extends ConsumerState<EmojiPillDetails> {
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
    selectedEmoji = ref.read(pillEmojiProvider).text;
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
              const Text(
                'Emoji',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    ref.read(pillEmojiProvider).text = emoji;
                  });
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.7),
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

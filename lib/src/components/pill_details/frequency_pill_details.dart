// ignore_for_file: unused_result

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class FrequencyPillDetails extends ConsumerWidget {
  const FrequencyPillDetails({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 250,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: CupertinoPicker(
                  backgroundColor: CupertinoColors.systemBackground,
                  itemExtent: 32,
                  children: List<Widget>.generate(48, (int index) {
                    return Center(
                      child: Text('${index + 1}'),
                    );
                  }),
                  onSelectedItemChanged: (int value) {
                    ref.read(pillFrequencyProvider.notifier).state = value + 1;
                  },
                ),
              ),
            );
          },
        );
      },
      child: SizedBox(
        width: 150, // Ograniczenie szerokości InputDecorator
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'F r e q u e n c y',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
              fontSize: 16, // Ustaw rozmiar czcionki dla tekstu etykiety
            ),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              var frequencyStorageInfo = ref.watch(pillFrequencyProvider);

              return Text(frequencyStorageInfo?.toString() ?? 'Select');
            },
          ),
        ),
      ),
    );
  }
}

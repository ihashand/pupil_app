// ignore_for_file: unused_result

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class DosagePetDetails extends ConsumerWidget {
  const DosagePetDetails({
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
                  itemExtent: 32,
                  children: List<Widget>.generate(48, (int index) {
                    return Center(
                      child: Text('${index + 1}'),
                    );
                  }),
                  onSelectedItemChanged: (int value) {
                    ref.read(pillDosageProvider.notifier).state = value + 1;
                  },
                ),
              ),
            );
          },
        );
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'D o s a g e',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            fontSize: 21, // Ustaw rozmiar czcionki dla tekstu etykiety
          ),
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final deprecatedStorageInfo = ref.watch(pillDosageProvider);
            return Text(deprecatedStorageInfo?.toString() ?? 'Select');
          },
        ),
      ),
    );
  }
}

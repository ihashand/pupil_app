import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberPickerDialog extends StatelessWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;

  const NumberPickerDialog({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    int currentValue = initialValue;

    return AlertDialog(
      title: const Text('Select Hours'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NumberPicker(
                value: currentValue,
                minValue: minValue,
                maxValue: maxValue,
                onChanged: (value) => setState(() => currentValue = value),
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark, fontSize: 11),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark, fontSize: 13),
          ),
          onPressed: () {
            Navigator.of(context).pop(currentValue);
          },
        ),
      ],
    );
  }
}

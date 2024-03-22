import 'package:flutter/material.dart';

class ManyHoursAlert extends StatelessWidget {
  const ManyHoursAlert({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
  });

  final int selectedHours;
  final int selectedMinutes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmation',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 24)),
      content: Text(
          'Are you sure that your walk time was $selectedHours:$selectedMinutes ?',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark, fontSize: 16)),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

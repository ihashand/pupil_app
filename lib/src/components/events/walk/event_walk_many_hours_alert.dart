import 'package:flutter/material.dart';

class EventWalkManyHoursAlert extends StatelessWidget {
  const EventWalkManyHoursAlert({
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
              color: Theme.of(context).primaryColorDark, fontSize: 20)),
      content: Text(
          'Are you sure that your walk time was $selectedHours:$selectedMinutes ?',
          style: TextStyle(color: Theme.of(context).primaryColorDark)),
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

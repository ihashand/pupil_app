import 'package:flutter/material.dart';

class EventWalkCancelWalk extends StatelessWidget {
  const EventWalkCancelWalk({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop(); // Anuluj dialog
      },
    );
  }
}

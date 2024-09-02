import 'package:flutter/material.dart';

class ActivityDataRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;

  const ActivityDataRow(
    this.context,
    this.label,
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}

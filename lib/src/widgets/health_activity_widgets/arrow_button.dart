import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ArrowButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 10,
        color: Theme.of(context).primaryColorDark,
        weight: 20,
      ),
      onPressed: onPressed,
    );
  }
}

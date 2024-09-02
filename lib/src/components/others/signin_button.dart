import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const SignInButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(15),
          child: Center(
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
        ));
  }
}

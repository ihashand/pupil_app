import 'package:flutter/material.dart';

class TextFieldReminder extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;

  const TextFieldReminder({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: controller.text.isNotEmpty
                  ? null
                  : isRequired
                      ? 'Required'
                      : 'Optional',
              labelStyle: const TextStyle(fontSize: 10),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}

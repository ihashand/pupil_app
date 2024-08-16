import 'package:flutter/material.dart';

class AddPetSegmentProgressBar extends StatelessWidget {
  final int totalSegments;
  final int filledSegments;
  final Color backgroundColor;
  final Color fillColor;

  const AddPetSegmentProgressBar({
    super.key,
    required this.totalSegments,
    required this.filledSegments,
    this.backgroundColor = Colors.grey,
    this.fillColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 30.0, right: 30, top: 20, bottom: 25),
      child: SizedBox(
        height: 8,
        child: Row(
          children: List.generate(
            totalSegments,
            (index) => Expanded(
              child: Container(
                margin:
                    EdgeInsets.only(right: index < totalSegments - 1 ? 5 : 0),
                decoration: BoxDecoration(
                  color: index < filledSegments ? fillColor : backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

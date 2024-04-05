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
    return SizedBox(
      height: 8,
      child: Row(
        children: List.generate(
          totalSegments,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < totalSegments - 1 ? 5 : 0),
              decoration: BoxDecoration(
                color: index < filledSegments ? fillColor : backgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

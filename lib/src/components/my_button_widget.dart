import 'package:flutter/material.dart';

class MyButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final String? assetName;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double opacity;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final String fontFamily;

  const MyButtonWidget({
    super.key,
    this.iconData,
    this.assetName,
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
    this.opacity = 1.0,
    this.borderRadius = 10.0,
    this.iconSize = 40.0,
    this.fontSize = 16.0,
    this.fontFamily = 'Arial',
  }) : assert(iconData != null || assetName != null,
            'You have to set iconData, or assetName');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: iconData != null
                ? Icon(iconData, color: Colors.white, size: iconSize)
                : Image.asset(assetName!, width: iconSize, height: iconSize),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class MyRectangleWidget extends StatelessWidget {
  final Widget? content;
  final String? text;
  final VoidCallback onTap;
  final Color color;
  final double opacity;
  final double borderRadius;
  final double width;
  final double height;
  final double fontSize;
  final String fontFamily;

  const MyRectangleWidget({
    super.key,
    this.content,
    this.text,
    required this.onTap,
    this.color = Colors.blue,
    this.opacity = 1.0,
    this.borderRadius = 10.0,
    this.width = 100.0,
    this.height = 50.0,
    this.fontSize = 16.0,
    this.fontFamily = 'Arial',
  }) : assert(content != null || text != null,
            'You have to set either content or text');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: content ??
                  Text(
                    text ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

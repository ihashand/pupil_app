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
  final double iconWeight;
  final double iconFill;
  final double iconGrade;
  final double iconOpticalSize;
  final Color iconColor;

  const MyButtonWidget(
      {Key? key,
      this.iconData,
      this.assetName,
      required this.label,
      required this.onTap,
      this.color = Colors.blue,
      this.opacity = 1.0,
      this.borderRadius = 10.0,
      this.iconSize = 40.0,
      this.fontSize = 16.0,
      this.fontFamily = 'San Francisco',
      this.iconWeight = 1,
      this.iconFill = 1,
      this.iconGrade = 1,
      this.iconOpticalSize = 1,
      this.iconColor = Colors.white})
      : assert(iconData != null || assetName != null,
            'You have to set iconData, or assetName');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: iconData != null
                ? Icon(
                    iconData,
                    color: iconColor,
                    size: iconSize,
                    weight: iconWeight,
                    fill: iconFill,
                    grade: iconGrade,
                    opticalSize: iconOpticalSize,
                  )
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
  final Widget? topContent;
  final Widget? bottomContent;
  final VoidCallback onTap;
  final Color? topColor;
  final String? imageAsset;
  final Color bottomColor;
  final double opacity;
  final double borderRadius;
  final double width;
  final double totalHeight;
  final double topHeight;
  final double bottomHeight;
  final double fontSize;
  final String fontFamily;

  const MyRectangleWidget({
    Key? key,
    this.topContent,
    this.bottomContent,
    required this.onTap,
    this.topColor,
    this.imageAsset,
    this.bottomColor = Colors.white,
    this.opacity = 1.0,
    this.borderRadius = 10.0,
    this.width = 100.0,
    this.totalHeight = 50.0,
    this.topHeight = double.infinity,
    this.bottomHeight = double.infinity,
    this.fontSize = 16.0,
    this.fontFamily = 'Arial',
  })  : assert(
          (topColor != null && imageAsset == null) ||
              (topColor == null && imageAsset != null),
          'You can only set either topColor or imageAsset, not both',
        ),
        assert(topContent != null || bottomContent != null,
            'You have to set either topContent or bottomContent');
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Rectangle
          Container(
            width: width,
            height: topHeight.isFinite ? topHeight : totalHeight / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
              color: topColor ?? bottomColor,
            ),
            child: imageAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                    child: Image(
                      image: ExactAssetImage(imageAsset!),
                      fit: BoxFit.cover,
                    ),
                  )
                : topContent,
          ),
          // 2. Bottom Rectangle
          Container(
            width: width,
            height: bottomHeight.isFinite ? bottomHeight : totalHeight / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              color: bottomColor.withOpacity(opacity),
            ),
            child: bottomContent ??
                Center(
                  child: Text(
                    'Default Text',
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

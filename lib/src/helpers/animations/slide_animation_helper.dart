import 'package:flutter/material.dart';

class SlideAnimationHelper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve curve;

  const SlideAnimationHelper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.beginOffset = const Offset(0, -1), // Start position (default: above)
    this.endOffset = Offset.zero, // End position (default: center)
    this.curve = Curves.easeOut, // Curve for smooth transition
  });

  @override
  createState() => _SlideAnimationHelperState();
}

class _SlideAnimationHelperState extends State<SlideAnimationHelper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _controller.forward(); // Start the animation when the widget is built
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

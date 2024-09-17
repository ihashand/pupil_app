import 'package:flutter/material.dart';

class HomeScreenShakeAnimation extends StatefulWidget {
  final Widget child;

  const HomeScreenShakeAnimation({super.key, required this.child});

  @override
  createState() => _HomeScreenShakeAnimationState();
}

class _HomeScreenShakeAnimationState extends State<HomeScreenShakeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.027, 0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.elasticIn,
    ));

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        _animationController?.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation!,
      child: widget.child,
    );
  }
}

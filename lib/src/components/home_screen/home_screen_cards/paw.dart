import 'package:flutter/material.dart';

class Paw extends StatefulWidget {
  final Color color;
  final int index;

  const Paw({super.key, required this.color, required this.index});

  @override
  createState() => PawState();
}

class PawState extends State<Paw> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool isFirstIteration = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: widget.index), () {
        _startAnimation();
      });
    });
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      // Check if it's the first iteration to apply the delay
      if (isFirstIteration) {
        Future.delayed(const Duration(seconds: 2), () {
          _controller.reverse().then((_) {
            isFirstIteration = false;
            _startAnimation();
          });
        });
      } else {
        // No delay for subsequent iterations
        _controller.reverse().then((_) {
          _startAnimation();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Image.asset(
        'assets/images/others/paw.png',
        width: 20,
        height: 20,
        color: widget.color,
      ),
    );
  }
}

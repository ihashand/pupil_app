import 'package:flutter/material.dart';

class Paw extends StatefulWidget {
  final Color color;
  final int index;

  const Paw({Key? key, required this.color, required this.index})
      : super(key: key);

  @override
  _PawState createState() => _PawState();
}

class _PawState extends State<Paw> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

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

    Future.delayed(Duration(seconds: widget.index), () {
      _startAnimation();
    });
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        _startAnimation();
      });
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

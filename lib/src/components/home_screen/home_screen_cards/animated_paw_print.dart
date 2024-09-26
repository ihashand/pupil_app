import 'package:flutter/material.dart';

class AnimatedPawPrint extends StatefulWidget {
  final bool isTodayExtended;
  final int strike;

  const AnimatedPawPrint({
    super.key,
    required this.isTodayExtended,
    required this.strike,
  });

  @override
  createState() => _AnimatedPawPrintState();
}

class _AnimatedPawPrintState extends State<AnimatedPawPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / 4,
            (index + 0.25) / 4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    // For fading out, we need to define the timing similarly but adjusted for fading out
    _fadeAnimations.addAll(List.generate(4, (index) {
      return Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index + 0.25) / 4,
            (index + 0.5) / 4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pawColor = Theme.of(context).primaryColorDark;

    return Container(
      width: 35,
      height: 50,
      child: Opacity(
        opacity: widget.isTodayExtended ? 1.0 : 0.3,
        child: widget.strike == 0
            ? Image.asset(
                'assets/images/others/paw.png',
                width: 25,
                height: 25,
                color: pawColor,
              )
            : Stack(
                children: [
                  // Paw print 1a
                  Positioned(
                    top: 45,
                    left: 5,
                    child: FadeTransition(
                      opacity: _fadeAnimations[0],
                      child: Image.asset(
                        'assets/images/others/paw.png',
                        width: 20,
                        height: 20,
                        color: pawColor,
                      ),
                    ),
                  ),
                  // Paw print 1b
                  Positioned(
                    top: 30,
                    left: 15,
                    child: FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: Image.asset(
                        'assets/images/others/paw.png',
                        width: 20,
                        height: 20,
                        color: pawColor,
                      ),
                    ),
                  ),
                  // Paw print 2a
                  Positioned(
                    top: 15,
                    left: 5,
                    child: FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: Image.asset(
                        'assets/images/others/paw.png',
                        width: 20,
                        height: 20,
                        color: pawColor,
                      ),
                    ),
                  ),
                  // Paw print 2b
                  Positioned(
                    top: 0,
                    left: 15,
                    child: FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: Image.asset(
                        'assets/images/others/paw.png',
                        width: 20,
                        height: 20,
                        color: pawColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

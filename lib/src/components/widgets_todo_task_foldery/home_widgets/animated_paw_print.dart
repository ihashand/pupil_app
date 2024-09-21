import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedPawPrint extends StatefulWidget {
  final bool isTodayExtended;
  final int strike;

  const AnimatedPawPrint({
    Key? key,
    required this.isTodayExtended,
    required this.strike,
  }) : super(key: key);

  @override
  _AnimatedPawPrintState createState() => _AnimatedPawPrintState();
}

class _AnimatedPawPrintState extends State<AnimatedPawPrint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeInOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.primary;
    final pawColor = Theme.of(context).primaryColorDark;
    ;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Opacity(
        opacity: widget.isTodayExtended ? 1.0 : 0.3,
        child: widget.strike == 0
            ? SvgPicture.asset(
                'assets/images/svg/paws1.svg',
                width: 25,
                height: 25,
                color: pawColor,
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: _fadeInOut,
                      child: SvgPicture.asset(
                        'assets/images/svg/paws1.svg',
                        width: 30,
                        height: 30,
                        color: pawColor,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: ReverseAnimation(_fadeInOut),
                      child: SvgPicture.asset(
                        'assets/images/svg/paws2.svg',
                        width: 30,
                        height: 30,
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

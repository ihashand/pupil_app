import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/paw.dart';

class AnimatedPawPrint extends StatelessWidget {
  final bool isTodayExtended;
  final int strike;

  const AnimatedPawPrint({
    super.key,
    required this.isTodayExtended,
    required this.strike,
  });

  @override
  Widget build(BuildContext context) {
    final pawColor = Theme.of(context).primaryColorDark;

    return SizedBox(
      width: 35,
      height: 50,
      child: Opacity(
        opacity: isTodayExtended ? 1.0 : 0.3,
        child: strike == 0
            ? Image.asset(
                'assets/images/others/paw.png',
                width: 25,
                height: 25,
                color: pawColor,
              )
            : Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 15,
                    child: Paw(color: pawColor, index: 3),
                  ),
                  Positioned(
                    top: 10,
                    left: 5,
                    child: Paw(color: pawColor, index: 2),
                  ),
                  Positioned(
                    top: 25,
                    left: 15,
                    child: Paw(color: pawColor, index: 1),
                  ),
                  Positioned(
                    top: 40,
                    left: 5,
                    child: Paw(color: pawColor, index: 0),
                  ),
                ],
              ),
      ),
    );
  }
}

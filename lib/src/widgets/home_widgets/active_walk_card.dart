import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/providers/walk_state_provider.dart';
import 'package:pet_diary/src/screens/walk_in_progress_screen.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class ActiveWalkCard extends ConsumerWidget {
  const ActiveWalkCard({
    super.key,
    required this.pets,
    this.buttonWidth = 120,
    this.buttonHeight = 35,
    this.buttonFontSize = 13,
  });

  final List<Pet> pets;
  final double buttonWidth;
  final double buttonHeight;
  final double buttonFontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkState = ref.watch(walkProvider);
    final walkNotifier = ref.read(walkProvider.notifier);

    if (!walkState.isWalking) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    walkNotifier.formatTime(walkState.seconds),
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'San Francisco',
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        walkState.currentSteps.toString(),
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'San Francisco',
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      Text(
                        walkState.status == 'walking' ? 'Walking' : 'Stopped',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff68a2b6),
                    minimumSize: Size(buttonWidth, buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalkInProgressScreen(
                          pets: pets,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Back to your walk',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

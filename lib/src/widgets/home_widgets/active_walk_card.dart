import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/providers/others_providers/walk_state_provider.dart';
import 'package:pet_diary/src/screens/walk_in_progress_screen.dart';

class ActiveWalkCard extends ConsumerWidget {
  const ActiveWalkCard({
    super.key,
    this.buttonWidth = 120,
    this.buttonHeight = 35,
    this.buttonFontSize = 13,
  });

  final double buttonWidth;
  final double buttonHeight;
  final double buttonFontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkState = ref.watch(walkProvider);
    final walkNotifier = ref.read(walkProvider.notifier);
    final activePets = ref.watch(activeWalkPetsProvider);

    if (!walkState.isWalking) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
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
                            walkState.status == 'walking'
                                ? 'Walking'
                                : 'Stopped',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: activePets.map((pet) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(pet.avatarImage),
                              radius: 20,
                            ),
                            Text(
                              pet.name,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff68a2b6),
                      minimumSize: Size(buttonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final isPaused = walkState.isPaused;
                          return AlertDialog(
                            title: Text(
                              isPaused ? 'Resume Walk' : 'Pause Walk',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            content: Text(
                              isPaused
                                  ? 'Are you sure you want to resume the walk?'
                                  : 'Are you sure you want to pause the walk?',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  walkNotifier.pauseWalk();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  isPaused ? 'Resume' : 'Pause',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      walkState.isPaused ? 'R e s u m e' : 'P a u s e',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
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
                            pets: activePets,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Y o u r  w a l k',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

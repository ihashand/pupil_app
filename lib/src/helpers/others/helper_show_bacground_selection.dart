import 'package:flutter/material.dart';

Future<void> showBackgroundSelectionDialog({
  required BuildContext context,
  required Function(String) onBackgroundSelected,
}) async {
  final List<String> backgroundPaths = [
    'assets/images/dog_backgrounds/dog_details_background_01.png',
    'assets/images/dog_backgrounds/dog_details_background_02.png',
    'assets/images/dog_backgrounds/dog_details_background_03.png',
    'assets/images/dog_backgrounds/dog_details_background_04.png',
    'assets/images/dog_backgrounds/dog_details_background_05.png',
    'assets/images/dog_backgrounds/dog_details_background_06.png',
    'assets/images/dog_backgrounds/dog_details_background_07.png',
    'assets/images/dog_backgrounds/dog_details_background_08.png',
    'assets/images/dog_backgrounds/dog_details_background_09.png',
    'assets/images/dog_backgrounds/dog_details_background_010.png',
    'assets/images/dog_backgrounds/dog_details_background_011.png',
    'assets/images/dog_backgrounds/dog_details_background_012.png',
  ];

  await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (BuildContext context) {
      return SizedBox(
        height: 280,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 15),
              child: Center(
                child: Text(
                  'B A C K G R O U N D',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.surface),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: backgroundPaths.length,
                itemBuilder: (BuildContext context, int index) {
                  final backgroundPath = backgroundPaths[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onBackgroundSelected(backgroundPath);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 250,
                        height: 175,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(backgroundPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

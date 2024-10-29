import 'package:flutter/material.dart';

Future<void> showAvatarSelectionDialog({
  required BuildContext context,
  required Function(String) onAvatarSelected,
}) async {
  final avatars = [
    'assets/images/dog_avatars/beagle.png',
    'assets/images/dog_avatars/border_collie.png',
    'assets/images/dog_avatars/buldog_francski.png',
    'assets/images/dog_avatars/chiuaua.png',
    'assets/images/dog_avatars/doberman.png',
    'assets/images/dog_avatars/husky.png',
    'assets/images/dog_avatars/jamnik.png',
    'assets/images/dog_avatars/kundelek.png',
    'assets/images/dog_avatars/labradrod.png',
    'assets/images/dog_avatars/owczarek.png',
    'assets/images/dog_avatars/rottwailer.png',
    'assets/images/dog_avatars/shitzu.png',
    'assets/images/dog_avatars/sznaucer.png',
    'assets/images/dog_avatars/west_highland_white_terier.png',
    'assets/images/dog_avatars/york.png',
  ];

  await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primary,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 15),
              child: Text(
                'A V A T A R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.surface),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(avatars.length, (index) {
                final avatarPath = avatars[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onAvatarSelected(avatarPath);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
                      backgroundImage: AssetImage(avatarPath),
                      radius: 40,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}

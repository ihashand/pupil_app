import 'package:flutter/material.dart';

Future<void> showAvatarSelectionDialog({
  required BuildContext context,
  required Function(String) onAvatarSelected,
}) async {
  // final picker = ImagePicker();
  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              // ListTile(
              //   leading: const Icon(Icons.camera_alt),
              //   title: const Text('Take a Photo'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     final pickedFile = await picker.pickImage(
              //       source: ImageSource.camera,
              //     );
              //     if (pickedFile != null) {
              //       final directory = await getApplicationDocumentsDirectory();
              //       final path = directory.path;
              //       final fileName = basename(pickedFile.path);
              //       final savedImage =
              //           await File(pickedFile.path).copy('$path/$fileName');
              //       onAvatarSelected(savedImage.path);
              //     }
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.photo),
              //   title: const Text('Choose from Gallery'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     final pickedFile = await picker.pickImage(
              //       source: ImageSource.gallery,
              //     );
              //     if (pickedFile != null) {
              //       onAvatarSelected(pickedFile.path);
              //     }
              //   },
              // ),
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Text(
                  'Pick an avatar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Divider(color: const Color(0xff68a2b6).withOpacity(0.2)),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(5, (index) {
                  final avatarIndex = index + 1;
                  final avatarPath =
                      'assets/images/dog_avatar_${avatarIndex.toString().padLeft(2, '0')}.png';
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onAvatarSelected(avatarPath);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatarPath),
                        radius: 10,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );
}

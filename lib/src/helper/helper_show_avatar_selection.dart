import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> showAvatarSelectionDialog({
  required BuildContext context,
  required Function(String) onAvatarSelected,
}) async {
  final picker = ImagePicker();

  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 1000,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final path = directory.path;
                    final fileName = basename(pickedFile.path);
                    final savedImage =
                        await File(pickedFile.path).copy('$path/$fileName');
                    onAvatarSelected(savedImage.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    onAvatarSelected(pickedFile.path);
                  }
                },
              ),
              const ListTile(
                title: Text(
                  'Defaults avatars',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
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
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatarPath),
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

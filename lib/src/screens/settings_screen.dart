import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_diary/src/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    User? user = ref.watch(userProvider); // Watch the user provider

    Future<void> showAvatarSelectionDialog() async {
      final picker = ImagePicker();
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await user?.updatePhotoURL(pickedFile.path);
                    ref.refresh(userProvider);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await user?.updatePhotoURL(pickedFile.path);
                    ref.refresh(userProvider);
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FirebaseAuth.instance.currentUser!.email!),
                    GestureDetector(
                      onTap: showAvatarSelectionDialog,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 12.0,
                        ),
                        child: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 201, 120, 197),
                          backgroundImage: ExactAssetImage(
                              FirebaseAuth.instance.currentUser!.photoURL ??
                                  ""),
                          radius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                padding: const EdgeInsets.all(12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dark Mode"),
                      CupertinoSwitch(
                        value: theme.isDarkMode,
                        onChanged: ((value) => theme.toggleTheme()),
                      ),
                    ]),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("L O G O U T"),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
          )
        ],
      ),
    );
  }
}

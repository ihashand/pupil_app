import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:pet_diary/src/providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final notificationTime = ref.watch(notificationTimeProvider);
    final isNotificationEnabled = ref.watch(notificationEnabledProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                padding: const EdgeInsets.all(12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Mood Notifications"),
                      CupertinoSwitch(
                        value: isNotificationEnabled,
                        onChanged: (value) {
                          ref.read(notificationEnabledProvider.notifier).state =
                              value;
                        },
                      ),
                    ]),
              ),
              if (isNotificationEnabled)
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Notification Time"),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: notificationTime,
                          );
                          if (picked != null && picked != notificationTime) {
                            ref.read(notificationTimeProvider.notifier).state =
                                picked;
                          }
                        },
                        child: Text(
                          notificationTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("LOGOUT"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                // ignore: use_build_context_synchronously
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
            ),
          )
        ],
      ),
    );
  }
}

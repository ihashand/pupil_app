import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:pet_diary/src/synchronization/sync_medicine_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

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
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                padding: const EdgeInsets.all(12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Synchronizuj dane"),
                      IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () async {
                          // Wyświetlenie komunikatu o rozpoczęciu synchronizacji
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Synchronizacja danych...'),
                            ),
                          );

                          // Uruchomienie funkcji synchronizacji danych
                          await SyncMedicineService.syncData();

                          // Wyświetlenie komunikatu o zakończeniu synchronizacji
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dane zostały zsynchronizowane.'),
                            ),
                          );
                        },
                      ),
                    ]),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("LOGOUT"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
            ),
          )
        ],
      ),
    );
  }
}

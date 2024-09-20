import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/components/report_widget/show_date_range_dialog.dart';

class GenerateReportCard extends ConsumerWidget {
  final String? petId;

  const GenerateReportCard({
    required this.petId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                'assets/images/others/raport.jpeg',
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () async {
                  final pet =
                      await ref.read(petServiceProvider).getPetById(petId!);
                  if (pet == null) {
                    // ignore: use_build_context_synchronously
                    await _showPetSelectionDialog(context, ref);
                  } else {
                    // ignore: use_build_context_synchronously
                    await showDateRangeDialog(context, ref, pet);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xff68a2b6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "G e n e r a t e  R e p o r t",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPetSelectionDialog(
      BuildContext context, WidgetRef ref) async {
    final asyncPets = ref
        .read(petFriendServiceProvider(FirebaseAuth.instance.currentUser!.uid));

    await showDialog(
      context: context,
      builder: (context) {
        return asyncPets.when(
          data: (pets) {
            final userPets = pets
                .where((pet) =>
                    pet.userId == FirebaseAuth.instance.currentUser!.uid)
                .toList();
            if (userPets.isEmpty) {
              return const AlertDialog(
                content: Text('No pets found.'),
              );
            }

            double dialogHeight;
            if (userPets.length == 1) {
              dialogHeight = 150;
            } else if (userPets.length == 2) {
              dialogHeight = 200;
            } else {
              dialogHeight = 220;
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select a Pet',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColorDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                ],
              ),
              content: SizedBox(
                height: dialogHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: userPets.map((pet) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(pet.avatarImage),
                                ),
                                title: Text(
                                  pet.name,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 14),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await showDateRangeDialog(context, ref, pet);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => AlertDialog(
            content: Text('Error: $error'),
          ),
        );
      },
    );
  }
}

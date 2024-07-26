import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/widgets/report_widget/show_date_range_dialog.dart';

class GenerateReportSection extends ConsumerWidget {
  final String? petId;

  const GenerateReportSection({
    required this.petId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xff68a2b6)),
          const SizedBox(height: 8),
          Text(
            "Generate a detailed health report in PDF, chose the date range and generate it for free!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          TextButton(
            onPressed: () async {
              final pet = await ref.read(petServiceProvider).getPetById(petId!);
              if (pet == null) {
                // ignore: use_build_context_synchronously
                await _showPetSelectionDialog(context, ref);
              } else {
                // ignore: use_build_context_synchronously
                await showDateRangeDialog(context, ref, pet);
              }
            },
            child: Text(
              "Generate Report",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

            return AlertDialog(
              title: const Text('Select a Pet'),
              content: SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: userPets.map((pet) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(pet.avatarImage),
                        ),
                        title: Text(pet.name),
                        onTap: () async {
                          Navigator.pop(context);
                          await showDateRangeDialog(context, ref, pet);
                        },
                      );
                    }).toList(),
                  ),
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

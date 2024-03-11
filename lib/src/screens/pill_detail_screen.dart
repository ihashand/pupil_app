// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/pill_details/dosage_pet_details.dart';
import 'package:pet_diary/src/components/pill_details/end_date_pill_details.dart';
import 'package:pet_diary/src/components/pill_details/frequency_pill_details.dart';
import 'package:pet_diary/src/components/pill_details/name_pet_details.dart';
import 'package:pet_diary/src/components/pill_details/start_date_pill_details.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import '../providers/pills_provider.dart';

// A screen for adding or editing pill details.
class PillDetailScreen extends ConsumerWidget {
  final Pill? pill;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String petId;

  PillDetailScreen(this.petId, {super.key, this.pill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pill == null ? 'A d d  p i l l' : 'E d i t  p i l l',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const NamePetDetails(),
              const SizedBox(height: 20),
              const FrequencyPillDetails(),
              const SizedBox(height: 20),
              const DosagePetDetails(),
              const SizedBox(height: 20),
              const StartDatePillDetails(),
              const SizedBox(height: 20),
              const EndDatePillDetails(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => savePill(context, ref, formKey, petId),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                child: const Text(
                  'S a v e',
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to save or update pill details.
  void savePill(BuildContext context, WidgetRef ref,
      GlobalKey<FormState> formKey, String petId) {
    if (formKey.currentState!.validate()) {
      final bool isNewPill = pill == null;
      final Pill newPill = isNewPill ? Pill() : pill!;
      final TextEditingController nameController =
          ref.read(pillNameControllerProvider);
      final DateTime dateController = ref.read(pillDateControllerProvider);

      if (isNewPill) {
        // Creating a new pill.
        final Pet? pet =
            ref.watch(petRepositoryProvider).value?.getPetById(petId);
        final String eventId = generateUniqueId();

        newPill.id = generateUniqueId();
        newPill.name = nameController.text;
        newPill.addDate = ref.read(pillDateControllerProvider);
        newPill.startDate = ref.read(pillStartDateControllerProvider);
        newPill.endDate = ref.read(pillEndDateControllerProvider);
        newPill.eventId = eventId;
        newPill.petId = petId;
        newPill.frequency = ref.read(pillFrequencyProvider).toString();
        newPill.dosage = ref.read(pillDosageProvider).toString();

        final Event newEvent = Event(
            id: eventId,
            title: newPill.name,
            description: newPill.addDate.toString(),
            date: DateTime.now(),
            durationTime: 0,
            value: 0,
            userId: pet!.userId,
            petId: petId,
            weightId: '',
            temperatureId: '',
            walkId: '',
            waterId: '',
            noteId: '',
            pillId: newPill.id);

        ref.read(eventRepositoryProvider).value?.addEvent(newEvent);

        nameController.clear();
        ref.refresh(eventRepositoryProvider);

        Navigator.of(context).pop(newPill);
      } else {
        // Updating an existing pill.
        Event? updatingEvent = ref
            .watch(eventRepositoryProvider)
            .value
            ?.getEventById(pill!.eventId);

        updatingEvent!.title = nameController.text;
        updatingEvent.description = dateController.toString();

        ref.read(eventRepositoryProvider).value?.updateEvent(updatingEvent);

        pill?.name = nameController.text;
        pill?.addDate = ref.read(pillDateControllerProvider);
        pill?.startDate = ref.read(pillStartDateControllerProvider);
        pill?.endDate = ref.read(pillEndDateControllerProvider);
        pill?.frequency = ref.read(pillFrequencyProvider).toString();
        pill?.dosage = ref.read(pillDosageProvider).toString();

        ref.refresh(eventRepositoryProvider);

        Navigator.of(context).pop(pill);
      }
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_note_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardNotes(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController contentTextController,
    WidgetRef ref) {
  return eventTypeCard(
    context,
    'Notes',
    'assets/images/health_event_card/notes.png',
    () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.71,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8, top: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColorDark),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 107),
                        child: Text(
                          'N O T E S',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            controller: titleController,
                            keyboardType: TextInputType.text,
                            cursorColor: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 30),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            controller: contentTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 10,
                            textAlign: TextAlign.start,
                            cursorColor: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 25, left: 25, bottom: 0, top: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff68a2b6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          if (titleController.text.isEmpty &&
                              contentTextController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Error',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 24,
                                    ),
                                  ),
                                  content: Text(
                                    'Fields cannot be empty.',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          String eventId = generateUniqueId();
                          String noteId = generateUniqueId();
                          EventNoteModel newNote = EventNoteModel(
                            id: noteId,
                            title: titleController.text,
                            eventId: eventId,
                            petId: '', // Wstaw właściwy petId
                            dateTime: DateTime.now(),
                            contentText: contentTextController.text,
                          );

                          Event newEvent = Event(
                            id: eventId,
                            title: 'Note',
                            eventDate: DateTime.now(),
                            dateWhenEventAdded: DateTime.now(),
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            petId: '', // Wstaw właściwy petId
                            weightId: '',
                            temperatureId: '',
                            walkId: '',
                            waterId: '',
                            noteId: newNote.id,
                            pillId: '',
                            description:
                                '${newNote.title} /n ${newNote.contentText}',
                            proffesionId: 'NONE',
                            personId: 'NONE',
                            avatarImage: 'assets/images/dog_avatar_014.png',
                            emoticon: '📝',
                            moodId: '',
                            stomachId: '',
                            psychicId: '',
                            stoolId: '',
                            urineId: '',
                            serviceId: '',
                            careId: '',
                          );

                          ref.read(eventServiceProvider).addEvent(newEvent);
                          ref.read(eventNoteServiceProvider).addNote(newNote);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'S A V E',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

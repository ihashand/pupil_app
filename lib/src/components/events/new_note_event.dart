import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/note_provider.dart';

class NewNoteEvent extends ConsumerStatefulWidget {
  final double iconSize;
  final Color iconColor;
  final String petId;
  final DateTime eventDateTime;

  const NewNoteEvent({
    super.key,
    required this.iconSize,
    required this.iconColor,
    required this.petId,
    required this.eventDateTime,
  });

  @override
  ConsumerState<NewNoteEvent> createState() => _NewNoteEventState();
}

class _NewNoteEventState extends ConsumerState<NewNoteEvent> {
  @override
  Widget build(BuildContext context) {
    const IconData iconData = Icons.note;
    var titleController = TextEditingController();
    var contentTextController = TextEditingController();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 250,
                      child: InputDecorator(
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                      ),
                      child: TextFormField(
                        controller: contentTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        textAlign: TextAlign.start,
                        cursorColor:
                            Theme.of(context).primaryColorDark.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
                        ),
                        onPressed: () async {
                          if (titleController.text.isEmpty &&
                              contentTextController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 24)),
                                  content: Text('Filelds can not be empty.',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 16)),
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
                                            fontSize: 20),
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
                          Note newNote = Note(
                              id: noteId,
                              title: titleController.text,
                              eventId: eventId,
                              petId: widget.petId,
                              dateTime: DateTime.now(),
                              contentText: contentTextController.text);

                          Event newEvent = Event(
                              id: eventId,
                              title: 'Note',
                              eventDate: widget.eventDateTime,
                              dateWhenEventAdded: DateTime.now(),
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              petId: widget.petId,
                              weightId: '',
                              temperatureId: '',
                              walkId: '',
                              waterId: '',
                              noteId: newNote.id,
                              pillId: '',
                              description:
                                  '${newNote.title} /n ${newNote.contentText}',
                              proffesionId: 'BRAK',
                              personId: 'BRAK',
                              avatarImage: 'assets/images/dog_avatar_014.png',
                              emoticon: '📝');

                          ref.read(eventServiceProvider).addEvent(newEvent);
                          ref.read(noteServiceProvider).addNote(newNote);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        iconData,
        size: widget.iconSize,
        color: widget.iconColor,
      ),
    );
  }
}

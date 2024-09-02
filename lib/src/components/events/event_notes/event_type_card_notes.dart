import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_note_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';

Widget eventTypeCardNotes(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController contentTextController,
    WidgetRef ref,
    String petId) {
  DateTime selectedDate = DateTime.now();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('dd-MM-yyyy').format(selectedDate),
  );

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
          return StatefulBuilder(
            builder: (context, setState) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Text(
                                    'N O T E S',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.check,
                                        color:
                                            Theme.of(context).primaryColorDark),
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
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              content: Text(
                                                'Fields cannot be empty.',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
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
                                        petId: petId,
                                        dateTime: selectedDate,
                                        contentText: contentTextController.text,
                                      );

                                      Event newEvent = Event(
                                        id: eventId,
                                        title: 'Note',
                                        eventDate: selectedDate,
                                        dateWhenEventAdded: selectedDate,
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        petId: petId,
                                        noteId: newNote.id,
                                        description:
                                            '${newNote.title} \n ${newNote.contentText}',
                                        avatarImage:
                                            'assets/images/dog_avatar_014.png',
                                        emoticon: '📝',
                                      );

                                      ref
                                          .read(eventServiceProvider)
                                          .addEvent(newEvent);
                                      ref
                                          .read(eventNoteServiceProvider)
                                          .addNote(newNote);

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: dateController,
                                            decoration: InputDecoration(
                                              labelText: 'Date',
                                              labelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: selectedDate,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2101),
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary,
                                                        onPrimary: Theme.of(
                                                                context)
                                                            .primaryColorDark,
                                                        onSurface: Theme.of(
                                                                context)
                                                            .primaryColorDark,
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor: Theme
                                                                  .of(context)
                                                              .primaryColorDark,
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null &&
                                                  picked != selectedDate) {
                                                setState(() {
                                                  selectedDate = picked;
                                                  dateController.text =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                      labelText: 'Title',
                                      labelStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                    cursorColor: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: contentTextController,
                                    decoration: InputDecoration(
                                      labelText: 'Note',
                                      labelStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: null,
                                    textAlign: TextAlign.start,
                                    cursorColor: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.5),
                                    onChanged: (text) {
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

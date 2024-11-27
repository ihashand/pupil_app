import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_note_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_note_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_type_card.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';

void showNotesModal(
  BuildContext context,
  TextEditingController titleController,
  TextEditingController contentTextController,
  WidgetRef ref, {
  String? petId,
  List<String>? petIds,
}) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool showDetails = false;
  final double screenHeight = MediaQuery.of(context).size.height;
  double initialSize = screenHeight > 800 ? 0.4 : 0.5;
  double detailsSize = screenHeight > 800 ? 0.57 : 0.75;
  double maxSize = screenHeight > 800 ? 1 : 1;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: showDetails ? detailsSize : initialSize,
            minChildSize: initialSize,
            maxChildSize: maxSize,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'N O T E S',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () {
                              if (titleController.text.isEmpty &&
                                  contentTextController.text.isEmpty) {
                                _showErrorDialog(
                                    context, 'Fields cannot be empty.');
                                return;
                              }
                              recordNoteEvent(
                                context,
                                ref,
                                titleController: titleController,
                                contentTextController: contentTextController,
                                petId: petId,
                                petIds: petIds,
                                selectedDate: selectedDate,
                                selectedTime: selectedTime,
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildTextContainer(
                              context,
                              titleController,
                              label: "Title",
                            ),
                            _buildTextContainer(
                              context,
                              contentTextController,
                              label: "Note",
                              isMultiline: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150,
                                height: 30,
                                child: showDetails
                                    ? IconButton(
                                        icon: const Icon(Icons.more_horiz),
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.6),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Text(
                                          "M O R E",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showDetails)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showStyledDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Date',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 13,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(selectedDate),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final TimeOfDay? pickedTime =
                                      await showStyledTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Time',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 13,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    selectedTime.format(context),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
    },
  );
}

// Kontener dla tekstu (tytuł/notatka)
Widget _buildTextContainer(
  BuildContext context,
  TextEditingController controller, {
  required String label,
  bool isMultiline = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
    child: SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorDark,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorDark,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType:
            isMultiline ? TextInputType.multiline : TextInputType.text,
        minLines: isMultiline ? 3 : 1,
        maxLines: isMultiline ? null : 1,
        textAlign: TextAlign.start,
        cursorColor: Theme.of(context).primaryColorDark.withOpacity(0.5),
      ),
    ),
  );
}

void recordNoteEvent(
  BuildContext context,
  WidgetRef ref, {
  required TextEditingController titleController,
  required TextEditingController contentTextController,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
  String? petId,
  List<String>? petIds,
}) {
  List<String> idsToHandle = petIds ?? [petId!];
  for (var id in idsToHandle) {
    String eventId = generateUniqueId();
    String noteId = generateUniqueId();
    EventNoteModel newNote = EventNoteModel(
      id: noteId,
      title: titleController.text,
      eventId: eventId,
      petId: id,
      dateTime: selectedDate,
      contentText: contentTextController.text,
      userId: FirebaseAuth.instance.currentUser!.uid,
      time: selectedTime,
    );

    Event newEvent = Event(
      id: eventId,
      title: 'Note',
      eventDate: selectedDate,
      dateWhenEventAdded: selectedDate,
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: id,
      noteId: newNote.id,
      description: '${newNote.title} \n ${newNote.contentText}',
      avatarImage: 'assets/images/dog_avatar_014.png',
      emoticon: '📝',
    );

    ref.read(eventServiceProvider).addEvent(newEvent);
    ref.read(eventNoteServiceProvider).addNote(newNote);
  }
}

// Funkcja wyświetlająca dialog błędu
void _showErrorDialog(BuildContext context, String message) {
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
          message,
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
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Główny widget eventTypeCardNotes
Widget eventTypeCardNotes(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController contentTextController,
    WidgetRef ref,
    {String? petId,
    List<String>? petIds}) {
  return eventTypeCard(
    context,
    'N O T E S',
    'assets/images/events_type_cards_no_background/notes.png',
    () {
      showNotesModal(context, titleController, contentTextController, ref,
          petId: petId, petIds: petIds);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/widgets/vet_visit_widgets/vet_visit_notes_screen.dart';

class VetVisitFollowUpScreen extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String petId;
  final String visitReason;
  final DateTime visitDate;
  final List<String> symptoms;
  final List<String> vaccines;

  const VetVisitFollowUpScreen({
    super.key,
    required this.ref,
    required this.petId,
    required this.visitReason,
    required this.visitDate,
    required this.symptoms,
    required this.vaccines,
  });

  @override
  createState() => _VetVisitFollowUpScreenState();
}

class _VetVisitFollowUpScreenState
    extends ConsumerState<VetVisitFollowUpScreen> {
  bool followUpRequired = false;
  DateTime? followUpDate;
  TimeOfDay? followUpTime;

  Future<void> _selectFollowUpDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: followUpDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: Theme.of(context).colorScheme.primary,
              primary: const Color(0xff68a2b6),
              onPrimary: Theme.of(context).primaryColorDark,
              onSurface: Theme.of(context).primaryColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != followUpDate) {
      setState(() {
        followUpDate = pickedDate;
      });
    }
  }

  Future<void> _selectFollowUpTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: followUpTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: Theme.of(context).colorScheme.primary,
              primary: const Color(0xff68a2b6),
              onPrimary: Theme.of(context).primaryColorDark,
              onSurface: Theme.of(context).primaryColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != followUpTime) {
      setState(() {
        followUpTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'F O L L O W  U P  V I S I T',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 20),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => VetVisitNotesScreen(
                  ref: widget.ref,
                  petId: widget.petId,
                  visitReason: widget.visitReason,
                  visitDate: widget.visitDate,
                  symptoms: widget.symptoms,
                  vaccines: widget.vaccines,
                  followUpRequired: followUpRequired,
                  followUpDate: followUpRequired &&
                          followUpDate != null &&
                          followUpTime != null
                      ? DateTime(
                          followUpDate!.year,
                          followUpDate!.month,
                          followUpDate!.day,
                          followUpTime!.hour,
                          followUpTime!.minute,
                        )
                      : null,
                ),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 40, bottom: 40, left: 60, right: 60),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Do you need a follow-up visit?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Follow-up required',
                        style: TextStyle(fontSize: 12)),
                    activeColor: Color(0xff68a2b6),
                    value: followUpRequired,
                    onChanged: (value) {
                      setState(() {
                        followUpRequired = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (followUpRequired)
                    Column(
                      children: [
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _selectFollowUpDate(context),
                            child: Text(
                              'Date: ${followUpDate != null ? DateFormat('dd-MM-yyyy').format(followUpDate!) : 'Not selected'}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _selectFollowUpTime(context),
                            child: Text(
                              'Time: ${followUpTime != null ? followUpTime!.format(context) : 'Not selected'}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

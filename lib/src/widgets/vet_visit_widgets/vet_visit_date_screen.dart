import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/widgets/vet_visit_widgets/vet_visit_follow_up_screen.dart';

class VetVisitDateScreen extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String petId;
  final String visitReason;
  final List<String> selectedSymptoms;
  final List<String> selectedVaccines;

  const VetVisitDateScreen({
    super.key,
    required this.ref,
    required this.petId,
    required this.visitReason,
    required this.selectedSymptoms,
    required this.selectedVaccines,
  });

  @override
  createState() => _VetVisitDateScreenState();
}

class _VetVisitDateScreenState extends ConsumerState<VetVisitDateScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
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
          'D A T E  &  T I M E',
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
                builder: (_) => VetVisitFollowUpScreen(
                  ref: widget.ref,
                  petId: widget.petId,
                  visitReason: widget.visitReason,
                  visitDate: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                  symptoms: widget.selectedSymptoms,
                  vaccines: widget.selectedVaccines,
                ),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                    'Select the date and time for the vet visit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Select Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _selectTime(context),
                      child: Text(
                        'Select Time: ${selectedTime.format(context)}',
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/widgets/report_widget/generate_print_vet_visit_raport.dart';

class VetVisitSummaryScreen extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String petId;
  final String visitReason;
  final DateTime visitDate;
  final List<String> symptoms;
  final List<String> vaccines;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final String notes;

  const VetVisitSummaryScreen({
    super.key,
    required this.ref,
    required this.petId,
    required this.visitReason,
    required this.visitDate,
    required this.symptoms,
    required this.vaccines,
    required this.followUpRequired,
    this.followUpDate,
    required this.notes,
  });

  @override
  _VetVisitSummaryScreenState createState() => _VetVisitSummaryScreenState();
}

class _VetVisitSummaryScreenState extends ConsumerState<VetVisitSummaryScreen> {
  Future<void> _saveVisit() async {
    final String vetVisitId = UniqueKey().toString();

    final Event event = Event(
      id: UniqueKey().toString(),
      title: 'Vet Visit',
      eventDate: widget.visitDate,
      dateWhenEventAdded: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: widget.petId,
      weightId: '',
      temperatureId: '',
      walkId: '',
      waterId: '',
      noteId: '',
      pillId: '',
      description: {
        'visitReason': widget.visitReason,
        'symptoms': widget.symptoms,
        'vaccines': widget.vaccines,
        'followUpRequired': widget.followUpRequired,
        'followUpDate': widget.followUpDate,
        'notes': widget.notes,
      }.toString(),
      proffesionId: '',
      personId: '',
      avatarImage: '',
      emoticon: '🐶',
      moodId: '',
      stomachId: '',
      stoolId: '',
      urineId: '',
      serviceId: '',
      careId: '',
      psychicId: '',
      vetVisitId: vetVisitId,
    );

    await widget.ref.read(eventServiceProvider).addEvent(event);

    if (widget.followUpRequired && widget.followUpDate != null) {
      // Dodanie kodu do tworzenia przypomnień dla wizyty kontrolnej
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Vet Visit - Summary',
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
            icon: const Icon(Icons.check, size: 20),
            onPressed: () async {
              await _saveVisit();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            onPressed: () async {
              await generateVetVisitReport(
                  widget.ref, widget.petId, widget.visitDate);
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(Icons.calendar_today, 'Visit Date:',
                      DateFormat('dd-MM-yyyy').format(widget.visitDate)),
                  _buildSummaryRow(Icons.access_time, 'Visit Time:',
                      TimeOfDay.fromDateTime(widget.visitDate).format(context)),
                  _buildSummaryRow(
                      Icons.description, 'Reason:', widget.visitReason),
                  if (widget.symptoms.isNotEmpty)
                    _buildSummaryRow(
                        Icons.sick, 'Symptoms:', widget.symptoms.join(', ')),
                  if (widget.vaccines.isNotEmpty)
                    _buildSummaryRow(Icons.vaccines, 'Vaccines:',
                        widget.vaccines.join(', ')),
                  if (widget.followUpRequired && widget.followUpDate != null)
                    _buildSummaryRow(Icons.date_range, 'Follow-up Visit:',
                        '${DateFormat('dd-MM-yyyy').format(widget.followUpDate!)} at ${TimeOfDay.fromDateTime(widget.followUpDate!).format(context)}'),
                  if (widget.notes.isNotEmpty)
                    _buildSummaryRow(Icons.note, 'Notes:', widget.notes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColorDark),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

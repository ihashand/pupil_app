import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/widgets/vet_visit_widgets/vet_visit_summary_screen.dart';

class VetVisitNotesScreen extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String petId;
  final String visitReason;
  final DateTime visitDate;
  final List<String> symptoms;
  final List<String> vaccines;
  final bool followUpRequired;
  final DateTime? followUpDate;

  const VetVisitNotesScreen({
    super.key,
    required this.ref,
    required this.petId,
    required this.visitReason,
    required this.visitDate,
    required this.symptoms,
    required this.vaccines,
    required this.followUpRequired,
    this.followUpDate,
  });

  @override
  createState() => _VetVisitNotesScreenState();
}

class _VetVisitNotesScreenState extends ConsumerState<VetVisitNotesScreen> {
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'N O T E S',
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
                builder: (_) => VetVisitSummaryScreen(
                  ref: widget.ref,
                  petId: widget.petId,
                  visitReason: widget.visitReason,
                  visitDate: widget.visitDate,
                  symptoms: widget.symptoms,
                  vaccines: widget.vaccines,
                  followUpRequired: widget.followUpRequired,
                  followUpDate: widget.followUpDate,
                  notes: notesController.text,
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
                  top: 20, bottom: 40, left: 30, right: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Add any additional notes for the vet visit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    maxLines: 5,
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

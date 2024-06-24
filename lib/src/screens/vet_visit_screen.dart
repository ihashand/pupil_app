import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VetVisitScreen extends StatefulWidget {
  const VetVisitScreen({super.key});

  @override
  createState() => _VetVisitScreenState();
}

class _VetVisitScreenState extends State<VetVisitScreen> {
  void _navigateToNextStep(String visitType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitDetailsScreen(visitType: visitType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vet Visit',
            style: TextStyle(color: Theme.of(context).primaryColorDark)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).primaryColorDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdfd785),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _navigateToNextStep('Checkup'),
              child: Text(
                'Checkup',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff68a2b6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _navigateToNextStep('Health Issue'),
              child: Text(
                'Health Issue',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdfd785),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _navigateToNextStep('Vaccination'),
              child: Text(
                'Vaccination',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff68a2b6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _navigateToNextStep('Nail Trimming'),
              child: Text(
                'Nail Trimming',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffdfd785),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _navigateToNextStep('Other'),
              child: Text(
                'Other',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitDetailsScreen extends StatefulWidget {
  final String visitType;
  const VisitDetailsScreen({super.key, required this.visitType});

  @override
  createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          visitType: widget.visitType,
          notes: _notesController.text,
          date: _selectedDate,
          time: _selectedTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Details',
            style: TextStyle(color: Theme.of(context).primaryColorDark)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).primaryColorDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Selected Type: ${widget.visitType}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text("Time: ${_selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff68a2b6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _navigateToSummary,
                child: Text(
                  'Next',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final String visitType;
  final String notes;
  final DateTime date;
  final TimeOfDay time;

  const SummaryScreen({
    super.key,
    required this.visitType,
    required this.notes,
    required this.date,
    required this.time,
  });

  void _confirmVisit(BuildContext context) {
    // Save the visit data to the database or state management
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary',
            style: TextStyle(color: Theme.of(context).primaryColorDark)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).primaryColorDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Theme.of(context).primaryColorDark),
            onPressed: () => _confirmVisit(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Visit Type'),
              subtitle: Text(visitType),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(date)),
            ),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(time.format(context)),
            ),
            ListTile(
              title: const Text('Notes'),
              subtitle: Text(notes),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';

void showAddMedicineName(BuildContext context, WidgetRef ref, String petId) {
  final nameController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'ADD MEDICINE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              Navigator.pop(context);
                              showAddMedicineDate(
                                context,
                                ref,
                                petId,
                                nameController.text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please enter a medicine name'),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Input for medicine name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      cursorColor: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineDate(
    BuildContext context, WidgetRef ref, String petId, String medicineName) {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'ADD DATE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddMedicineType(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Start Date
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle:
                          Text(DateFormat('dd-MM-yyyy').format(startDate)),
                      trailing: Icon(Icons.calendar_today,
                          color: Theme.of(context).primaryColorDark),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            startDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // End Date
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(DateFormat('dd-MM-yyyy').format(endDate)),
                      trailing: Icon(Icons.calendar_today,
                          color: Theme.of(context).primaryColorDark),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            endDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineType(BuildContext context, WidgetRef ref, String petId,
    String medicineName, DateTime startDate, DateTime endDate) {
  List<String> medicineTypes = [
    'Capsule',
    'Tablet',
    'Liquid',
    'Aerosol',
    'Suppository',
    'Inhaler',
    'Cream',
    'Drops',
    'Ointment',
    'Foam',
    'Injection',
    'Other',
  ];
  String selectedType = medicineTypes[0];
  final TextEditingController otherTypeController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'SELECT TYPE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.pop(context);
                            String medicineType = selectedType == 'Other'
                                ? otherTypeController.text
                                : selectedType;

                            showAddMedicineStrength(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Dropdown to select the type of medicine
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Medicine Type',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      value: selectedType,
                      items: medicineTypes
                          .map((type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedType == 'Other')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: otherTypeController,
                        decoration: InputDecoration(
                          labelText: 'Other Medicine Type',
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineStrength(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType) {
  final strengthController = TextEditingController();
  List<String> units = ['mg', 'mcg', 'g', 'ml', '%'];
  String selectedUnit = units[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'MEDICINE STRENGTH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddMedicineSchedule(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
                              strengthController.text,
                              selectedUnit,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Input for medicine strength
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: strengthController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Strength',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      cursorColor: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown to select the unit
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      value: selectedUnit,
                      items: units
                          .map((unit) => DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineSchedule(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType,
    String strength,
    String unit) {
  final frequencyController = TextEditingController();
  bool isCustomSchedule = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'MEDICINE SCHEDULE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddMedicineEmoji(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
                              strength,
                              unit,
                              frequencyController.text,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Input for frequency
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: frequencyController,
                      decoration: InputDecoration(
                        labelText: 'How many times per day?',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      cursorColor: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Switch for custom schedule
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SwitchListTile(
                    title: const Text('Custom Schedule'),
                    value: isCustomSchedule,
                    onChanged: (bool value) {
                      setState(() {
                        isCustomSchedule = value;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineEmoji(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType,
    String strength,
    String unit,
    String frequency) {
  List<String> emojis = ['💊', '💉', '🧴', '🩹', '💧', '🧪', '🧬'];
  String selectedEmoji = emojis[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with "X" and title
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
                          'SELECT EMOJI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColorDark),
                          onPressed: () {
                            Navigator.pop(context);
                            showAddMedicineSummary(
                              context,
                              ref,
                              petId,
                              medicineName,
                              startDate,
                              endDate,
                              medicineType,
                              strength,
                              unit,
                              frequency,
                              selectedEmoji,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Emoji selection
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10.0,
                    children: emojis.map((emoji) {
                      bool isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).primaryColorDark,
                                    width: 2)
                                : null,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}

void showAddMedicineSummary(
    BuildContext context,
    WidgetRef ref,
    String petId,
    String medicineName,
    DateTime startDate,
    DateTime endDate,
    String medicineType,
    String strength,
    String unit,
    String frequency,
    String emoji) {
  final formKey = GlobalKey<FormState>();

  void saveMedicine() async {
    if (formKey.currentState?.validate() ?? false) {
      final newMedicine = EventMedicineModel(
        id: generateUniqueId(),
        name: medicineName,
        petId: petId,
        eventId: generateUniqueId(),
        frequency: frequency,
        dosage: '$strength $unit',
        emoji: emoji,
        startDate: startDate,
        endDate: endDate,
        remindersEnabled: false,
      );

      await ref.read(eventMedicineServiceProvider).addMedicine(newMedicine);

      Navigator.of(context).pop(); // Close the modal after saving
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with "X" and title
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
                            'REVIEW & CONFIRM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: saveMedicine,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Review details of the medicine
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                            context, 'Medicine Name', medicineName),
                        _buildSummaryRow(context, 'Start Date',
                            DateFormat('dd-MM-yyyy').format(startDate)),
                        _buildSummaryRow(context, 'End Date',
                            DateFormat('dd-MM-yyyy').format(endDate)),
                        _buildSummaryRow(context, 'Type', medicineType),
                        _buildSummaryRow(
                            context, 'Strength', '$strength $unit'),
                        _buildSummaryRow(context, 'Frequency', frequency),
                        _buildSummaryRow(context, 'Emoji', emoji),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildSummaryRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ],
    ),
  );
}
